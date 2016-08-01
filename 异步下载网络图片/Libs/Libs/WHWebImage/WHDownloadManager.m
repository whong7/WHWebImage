//
//  WHDownloadManager.m
//  异步下载网络图片
//
//  Created by whong7 on 16/8/1.
//  Copyright © 2016年 whong7. All rights reserved.
//

#import "WHDownloadManager.h"
#import "NSString+path.h"

@interface WHDownloadManager ()

/**
 *  图片内存缓存
 */
@property (nonatomic, strong) NSMutableDictionary *imageCache;

/**
 *  操作缓存
 */
@property (nonatomic, strong) NSMutableDictionary *operationCache;

/**
 *  队列
 */
@property (nonatomic, strong) NSOperationQueue *queue;

@end

@implementation WHDownloadManager

+ (instancetype)sharedManager {
    static WHDownloadManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)downloadImageWithUrlString:(NSString *)urlString compeletion:(void(^)(UIImage *))compeletion 
    {
        
        
        //MARK:断言
        // 断言:可以判断条件是否成立,如果不成立,会崩溃
        // 断言只作用于开发期间.给程序员使用的.程序一旦打包,该代码是不存在
        NSAssert(compeletion != nil, @"必需传入会掉的block");
        
        
        //MARK:1-首先判断内存中有没有
        UIImage *cacheImage = self.imageCache[urlString];
        
        if (cacheImage != nil) {
            //MARK:1.1 如果有直接使用block将图片回调
            compeletion(cacheImage);
            return;
        }
        
        
        //MARK:2-再判断沙盒中有没有
           //MARK:2.1-取到沙盒的路径
            NSString *sanboxPath = [urlString appendCachePath];
            cacheImage = [UIImage imageWithContentsOfFile:sanboxPath];
            if (cacheImage != nil) {
                NSLog(@"从沙盒中取");
                //MARK:2.2 如果沙盒中有,使用block将图片回调
                compeletion(cacheImage);
                //MARK:2.3 把图片保存到内存中一份,以便下次直接从内存中加载
                [self.imageCache setObject:cacheImage forKey:urlString];
                return;
            }

        
        //MARK:3-判断操作有没有
        if (self.operationCache[urlString] != nil) {
            NSLog(@"操作已存在，代表正在下载，请稍等");
            return;
        }
        
        //MARK:4-创建一个操作下载图片
        NSLog(@"创建操作去下载图片");
        
    }


#pragma mark - 初始化
- (instancetype)init
{
    self = [super init];
    if (self) {
        // 初始化两个缓存&一个队列
        self.imageCache = [NSMutableDictionary dictionary];
        self.operationCache = [NSMutableDictionary dictionary];
        self.queue = [NSOperationQueue new];
        
//        // 注册内存警告的通知
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(memoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}
@end
