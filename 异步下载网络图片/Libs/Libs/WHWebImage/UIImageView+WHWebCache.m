//
//  UIImageView+WHWebCache.m
//  异步下载网络图片
//
//  Created by whong7 on 16/8/2.
//  Copyright © 2016年 whong7. All rights reserved.
//

#import "UIImageView+WHWebCache.h"
#import "WHDownloadManager.h"
#import <objc/runtime.h>

const char *kUrlString = "kUrlString";

@implementation UIImageView (WHWebCache)

#pragma mark - 下载入口逻辑判断
//给cell的iconView添加一个属性，即给cell添加一个属性，当前cell是否还有其他下载图片的操作，操作是不是正确的。urlstring是一个辨识符，每次进行下载的时候都应该进行判别。
-(void)wh_setImageWithUrlString:(NSString *)string placeholderImage:(UIImage *)image
{
    
    self.image = image;
    // 判断之前下载的图片,如果有,就取消之前的下载
    
    if (self.urlString != nil && ![self.urlString isEqualToString:string]) {
        NSLog(@"之前的操作被取消了");
        // 取消掉之前的下载操作
        // 如何才能取到之前的下载地址 --> 在每一次下载的时候,将下载地址保存一下
        /**
         1. 下载`爸爸去哪儿`的时候,将该图片地址保存起来
         2. 当用户滑动到最上面的时候,又会去下载植物,在这个时候就可以取到上一次的下载地址
         3. 再通过地址去取消`爸爸去哪儿`的下载操作
         
         */
        [[WHDownloadManager sharedManager] cancelOperationWithUrlString:self.urlString];
    }
    
    // 记录`爸爸去哪儿`的时候,将该图片地址保存起来
    self.urlString = string;
    
    // 再下载新的图片
    /**
     如果每一张图片下载的时候不一定,那么还是会产生图片错乱 ,怎么解决
     */
    [[WHDownloadManager sharedManager] downloadImageWithUrlString:string compeletion:^(UIImage *image) {
        NSLog(@"已下载好的image:%@", image);
        self.image = image;
        // 当前图片已下载成功 : 当前图片已经下载成功了,所以不需要再保存图片地址,因为下次再进来的时候就重新去下载另外一张图片
        self.urlString = nil;
    }];

}

#pragma mark - 定义分类属性-运行时
- (NSString *)urlString {
    return objc_getAssociatedObject(self, kUrlString);
}

- (void)setUrlString:(NSString *)urlString {
    // 使用对象关联 --> 属于运行时里面的东西 --> 应用场景就是在分类中,定义属性,给当前对象保存值
    /**
     参数
     1. 要给谁关联
     2. 关联的key
     3. 关联的值
     4. 关联策略
     
     
     OBJC_ASSOCIATION_ASSIGN = 0,
     OBJC_ASSOCIATION_RETAIN_NONATOMIC = 1, < Specifies a strong reference to the associated object.
     *   The association is not made atomically.
     OBJC_ASSOCIATION_COPY_NONATOMIC = 3,   < Specifies that the associated object is copied.
     *   The association is not made atomically.
     OBJC_ASSOCIATION_RETAIN = 01401,       < Specifies a strong reference to the associated object.
     *   The association is made atomically.
     OBJC_ASSOCIATION_COPY = 01403          < Specifies that the associated object is copied.
     *   The association is made atomically.
     */
    objc_setAssociatedObject(self, kUrlString, urlString, OBJC_ASSOCIATION_COPY_NONATOMIC);
}


@end
