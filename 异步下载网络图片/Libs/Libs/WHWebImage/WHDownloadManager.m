//
//  WHDownloadManager.m
//  异步下载网络图片
//
//  Created by whong7 on 16/8/1.
//  Copyright © 2016年 whong7. All rights reserved.
//

#import "WHDownloadManager.h"
#import "NSString+path.h"
#import "WHDownloadOperation.h"

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
#pragma mark - 进行下载前逻辑判断

- (void)downloadImageWithUrlString:(NSString *)urlString compeletion:(void(^)(UIImage *))compeletion 
    {
//        
//        //MARK:断言
//        // 断言:可以判断条件是否成立,如果不成立,会崩溃
//        // 断言只作用于开发期间.给程序员使用的.程序一旦打包,该代码是不存在
//        NSAssert(compeletion != nil, @"必需传入会掉的block");
//        
//        
//        //MARK:1-首先判断内存中有没有
//        UIImage *cacheImage = self.imageCache[urlString];
//        
//        if (cacheImage != nil) {
//            NSLog(@"从内存中取");
//            //MARK:1.1 如果有直接使用block将图片回调
//            compeletion(cacheImage);
//            return;
//        }
//        
//        
//        //MARK:2-再判断沙盒中有没有
//           //MARK:2.1-取到沙盒的路径
//            NSString *sanboxPath = [urlString appendCachePath];
//            cacheImage = [UIImage imageWithContentsOfFile:sanboxPath];
//            if (cacheImage != nil) {
//                NSLog(@"从沙盒中取");
//                //MARK:2.2 如果沙盒中有,使用block将图片回调
//                compeletion(cacheImage);
//                //MARK:2.3 把图片保存到内存中一份,以便下次直接从内存中加载
//                [self.imageCache setObject:cacheImage forKey:urlString];
//                return;
//            }

        
        //MARK:3-判断操作有没有
        //防止连续创建相同下载操作
        if (self.operationCache[urlString] != nil) {
            NSLog(@"操作已存在，代表正在下载，请稍等");
            return;
        }
        
        //MARK:4-创建一个操作下载图片
        WHDownloadOperation *op = [WHDownloadOperation operationWithUrlString:urlString];
        
        __weak WHDownloadOperation *weakSelf = op;
        // 4.1 如何监听图片下载完成
        [op setCompletionBlock:^{//子线程中
            
            //图像错位调试
            [NSThread sleepForTimeInterval:arc4random_uniform(10)];
            
            // 取到图片
            UIImage *image = weakSelf.image;
            
            // 回到主线程调用block,将image传出去
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                //nil不能存储到字典中
                if (image != nil) {
                    // 保存到内存中一份
                    [self.imageCache setObject:image forKey:urlString];
                }
                
                // 将当前操作从缓存中移除
                [self.operationCache removeObjectForKey:urlString];
                compeletion(image);
            }];
        }];

        
        // 将操作添加到操作的缓存
        [self.operationCache setObject:op forKey:urlString];
        //MARK:5-将操作添加到队列
        [self.queue addOperation:op];
        
        
        //
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
        
        // 注册内存警告的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(memoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}


#pragma mark - 接收到内存警告的通知之后要做的事情

- (void)memoryWarning {
    NSLog(@"收到内存警告");
    // 1. 清除图片
    [self.imageCache removeAllObjects];
    // 2. 清除操作
    [self.operationCache removeAllObjects];
    // 3. 取消队列中所有的操作
    [self.queue cancelAllOperations];
}

#pragma mark - 在此里面去移除通知,虽然当前是一个单例

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
