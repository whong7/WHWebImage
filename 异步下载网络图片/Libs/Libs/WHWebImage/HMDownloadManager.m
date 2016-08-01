//
//  HMDownloadManager.m
//  异步下载网络图片
//
//  Created by whong7 on 16/8/1.
//  Copyright © 2016年 whong7. All rights reserved.
//

#import "HMDownloadManager.h"

@implementation HMDownloadManager

+ (instancetype)sharedManager {
    static HMDownloadManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)downloadImageWithUrlString:(NSString *)urlString compeletion:(void(^)(UIImage *))compeletion 
    {
        
    }

@end
