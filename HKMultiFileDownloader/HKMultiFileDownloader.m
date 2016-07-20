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

@property (nonatomic, strong) NSArray *fileInfos;

@end

@implementation HKMultiFileDownloader

+ (instancetype)hk_downloadWithURL:(NSString*)URL completion:(HKMultiFileCompletion)completion{
    if (URL.length == 0) {
        completion([[NSError alloc] init], nil);
        return nil;
    }
    
    HKMultiFileDownloader *downloader = [[HKMultiFileDownloader alloc] initWithURL:URL];
    [downloader downloadWithCompletion:completion];
    return downloader;
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
        _totalLength = [self requestFilesize];
        if (self.totalLength == 0) {
            if (self.completion){
                completion([[NSError alloc] init], nil);
            }
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
                self.completion([[NSError alloc] init], nil);
            }
        }else{
            if (self.completion) {
                self.completion(nil, [mudata copy]);
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
