//
//  WHDownloadOperation.m
//  异步下载网络图片
//
//  Created by whong7 on 16/8/1.
//  Copyright © 2016年 whong7. All rights reserved.
//

#import "WHDownloadOperation.h"


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


-(void)main
{
    
}


@end
