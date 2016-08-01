//
//  WHDownloadOperation.m
//  异步下载网络图片
//
//  Created by whong7 on 16/8/1.
//  Copyright © 2016年 whong7. All rights reserved.
//

#import "WHDownloadOperation.h"
#import "NSString+path.h"


@interface WHDownloadOperation ()

@property(nonatomic,copy)NSString *urlString;

@end


@implementation WHDownloadOperation


+ (instancetype)operationWithUrlString:(NSString *)urlString
{
    //初始化操作
    WHDownloadOperation *op = [WHDownloadOperation new];
    //记录urlString
    op.urlString = urlString;
    return op;
    
}
- (void)main {
    
    // [NSThread sleepForTimeInterval:arc4random_uniform(10)];
    
    // 1. 通过地址字符初始化NSURL
    NSURL *url = [NSURL URLWithString:self.urlString];
    // 2. 通过 URL 获取二进制数据
    NSData *data = [NSData dataWithContentsOfURL:url];
    // 3. 将二进制数据转成 UIImage
    UIImage *image = [UIImage imageWithData:data];
    
    // 4. 将二进制数据写入沙盒
    [data writeToFile:[self.urlString appendCachePath] atomically:true];
    
    self.image = image;
    
}

@end