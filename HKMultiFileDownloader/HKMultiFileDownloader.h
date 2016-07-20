//
//  HKMultiFileDownloader.h
//  HKMultiFileDownloader
//
//  Created by HuangKai on 16/4/25.
//  Copyright © 2016年 HuangKai. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^HKMultiFileCompletion)(NSData *data, NSUInteger totalLength);


@interface HKMultiFileDownloader : NSObject

/**
 *  下载地址
 */
@property (nonatomic, copy, readonly) NSString *URL;

/**
 *  请求数量，默认3
 */
@property (nonatomic, assign) NSInteger requestCount;

/**
 *  网络请求超时时间，默认2sec
 */
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

/**
 *  多线程下载文件
 *
 *  @param URL        HTTP链接
 *  @param completion  HKMultiFileCompletion
 */
+ (void)hk_downloadWithURL:(NSString*)URL completion:(HKMultiFileCompletion)completion;

/**
 *  初始化方法
 *
 *  @param URL HTTP链接
 *
 *  @return instancetype
 */
- (instancetype)initWithURL:(NSString *)URL;

/**
 *  下载文件的方法
 *
 *  @param completion HKMultiFileCompletion
 */
- (void)downloadWithCompletion:(HKMultiFileCompletion)completion;

@end
