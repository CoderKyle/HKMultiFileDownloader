//
//  HKMultiFileDownloader.m
//  HKMultiFileDownloader
//
//  Created by HuangKai on 16/4/25.
//  Copyright © 2016年 HuangKai. All rights reserved.
//

#import "HKMultiFileDownloader.h"

@interface HKFileInfo : NSObject

@property (nonatomic, copy) NSString *URL;
@property (nonatomic, assign) long long beginSize;
@property (nonatomic, assign) long long endSize;
@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSError *error;

- (void)start;

@end

@implementation HKFileInfo

- (void)start{
    NSURL *url = [NSURL URLWithString:self.URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    // 设置请求头信息
    NSString *value = [NSString stringWithFormat:@"bytes=%lld-%lld", self.beginSize, self.endSize];
    [request setValue:value forHTTPHeaderField:@"Range"];
    NSError *error = nil;
    self.data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    self.error = error;
    //    NSLog(@"\nindex:%ld,\nlength:%ld,\n thread:%@,\n %lld == %lld", self.index, (long)(self.endSize - self.beginSize), [NSThread currentThread], self.beginSize, self.endSize);
}

@end

@interface HKMultiFileDownloader()

@property (nonatomic, copy) HKMultiFileCompletion completion;

@property (nonatomic, assign) long long totalLength;

@property (nonatomic, strong) NSArray *fileInfos;

@end

@implementation HKMultiFileDownloader

+ (void)hk_downloadWithURL:(NSString*)URL completion:(HKMultiFileCompletion)completion{
    if (URL.length == 0) {
        completion(nil, 0);
        return;
    }
    
    HKMultiFileDownloader *downloader = [[HKMultiFileDownloader alloc] initWithURL:URL];
    NSDate *beginDate = [NSDate date];
    [downloader downloadWithCompletion:^(NSData *data, NSUInteger totalLength) {
        NSDate *endDate = [NSDate date];
        if (data) {
            NSLog(@"线程数量：%ld ,多线程耗时:%f", (long)downloader.requestCount, [endDate timeIntervalSinceDate:beginDate]);
        }else{
            NSLog(@"线程数量：%ld ,下载出错", (long)downloader.requestCount);
        }
        if (completion) {
            completion(data, totalLength);
        }
    }];
}

- (instancetype)initWithURL:(NSString *)URL {
    self = [super init];
    if (self) {
        self.requestCount = 3;
        self.timeoutInterval = 2;
        _URL = URL;
    }
    return self;
}

- (void)downloadWithCompletion:(HKMultiFileCompletion)completion {
    if (self.URL.length == 0) {
        if (completion) {
            completion(nil, 0);
        }
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        self.completion = completion;
        self.totalLength = [self requestFilesize];
        if (self.totalLength == 0) {
            if (self.completion) completion(nil, 0);
            return;
        }
        
        NSMutableArray *fileInfos = [NSMutableArray array];
        // 每条路径的下载量
        long long size = 0;
        if (self.totalLength % self.requestCount == 0) {
            size = self.totalLength / self.requestCount;
        } else {
            size = self.totalLength / self.requestCount + 1;
        }
        
        for (NSInteger index = 0; index < self.requestCount; index ++) {
            HKFileInfo *fileInfo = [[HKFileInfo alloc] init];
            fileInfo.URL = self.URL;
            fileInfo.beginSize = index * size;
            fileInfo.endSize = fileInfo.beginSize + size - 1;
            fileInfo.index = index;
            [fileInfos addObject:fileInfo];
        }
        self.fileInfos = fileInfos.copy;
        [self downloader];
    });
}

- (void)downloader {
    dispatch_queue_t dispatchQueue = dispatch_queue_create("NET.GOOME,DOWNLODER", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t dispatchGroup = dispatch_group_create();
    
    for (HKFileInfo *fileInfo in self.fileInfos) {
        dispatch_group_async(dispatchGroup, dispatchQueue, ^(){
            [fileInfo start];
        });
    }
    
    dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), ^(){
        NSMutableData *mudata = [NSMutableData data];
        for (HKFileInfo *fileInfo in self.fileInfos) {
            if (!fileInfo.error) {
                [mudata appendData:fileInfo.data];
            }else{
                break;
            }
        }
        if (mudata.length != self.totalLength) {
            if (self.completion) {
                self.completion(nil, self.totalLength);
            }
        }else{
            if (self.completion) {
                self.completion([mudata copy], self.totalLength);
            }
        }
    });
}

- (long long)requestFilesize {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.URL]];
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    request.timeoutInterval = self.timeoutInterval;
    request.HTTPMethod = @"HEAD";
    NSURLResponse *response = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    return response.expectedContentLength;
}

@end
