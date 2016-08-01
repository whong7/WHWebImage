//
//  WHAppInfo.h
//  异步下载网络图片
//
//  Created by whong7 on 16/8/1.
//  Copyright © 2016年 whong7. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WHAppInfo : NSObject


@property(nonatomic,copy)NSString *download;
@property(nonatomic,copy)NSString *icon;
@property(nonatomic,copy)NSString *name;

/**
 *  当前模型对象的image
 */
@property(nonatomic,strong)UIImage *image;




@end
