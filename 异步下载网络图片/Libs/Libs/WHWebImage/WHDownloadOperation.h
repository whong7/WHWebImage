//
//  WHDownloadOperation.h
//  异步下载网络图片
//
//  Created by whong7 on 16/8/1.
//  Copyright © 2016年 whong7. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WHDownloadOperation : NSOperation

@property (nonatomic, strong) UIImage *image;

/**
 *  通过一个urlString创建一个操作
 *
 *  @param urlString <#urlString description#>
 */
+ (instancetype)operationWithUrlString:(NSString *)urlString;

@end
