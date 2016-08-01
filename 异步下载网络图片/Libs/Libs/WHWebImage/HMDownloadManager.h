//
//  HMDownloadManager.h
//  异步下载网络图片
//
//  Created by whong7 on 16/8/1.
//  Copyright © 2016年 whong7. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HMDownloadManager : NSObject

/**
 *  全局访问点
 *
 *  @return <#return value description#>
 */
+ (instancetype)sharedManager;


// 提供一个给外界调用的下载图片的方法
// 异步的操作是不能直接给当前函数提供返回值的,需要使用 block 进行回调

/**
 *  通过图片地址,下载图片,并且使用block将异步下载的图片进行回调
 *
 *  @param urlString   <#urlString description#>
 *  @param compeletion <#compeletion description#>
 */
- (void)downloadImageWithUrlString:(NSString *)urlString compeletion:(void(^)(UIImage *))compeletion;



@end
