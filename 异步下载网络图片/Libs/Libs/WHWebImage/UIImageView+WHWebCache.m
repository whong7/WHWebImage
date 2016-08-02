//
//  UIImageView+WHWebCache.m
//  异步下载网络图片
//
//  Created by whong7 on 16/8/2.
//  Copyright © 2016年 whong7. All rights reserved.
//

#import "UIImageView+WHWebCache.h"
#import "WHDownloadManager.h"

@implementation UIImageView (WHWebCache)

-(void)wh_setImageWithUrlString:(NSString *)string placeholderImage:(UIImage *)image
{
        self.image = image;
        [[WHDownloadManager sharedManager] downloadImageWithUrlString:string compeletion:^(UIImage *image) {
            self.image = image;
        }];
}

@end
