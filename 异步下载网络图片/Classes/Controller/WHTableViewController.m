//
//  WHTableViewController.m
//  异步下载网络图片
//
//  Created by whong7 on 16/8/1.
//  Copyright © 2016年 whong7. All rights reserved.
//

#import "WHTableViewController.h"
#import "AFHTTPSessionManager.h"
#import "WHAppInfo.h"
#import "WHTableViewCell.h"
#import "NSString+path.h"



@interface WHTableViewController ()

/**
 *  装有模型信息的数组
 */
@property (nonatomic, strong) NSMutableArray *appInfos;
/**
 *  操作
 */
@property (nonatomic, strong) NSOperationQueue *queue;

/**
 *  图片缓存的字典 <key: 图片地址, value: 图片>;
 */
@property (nonatomic, strong) NSMutableDictionary *imageCache;

/**
 *  下载操作的缓存,避免重复下载
 */
@property (nonatomic, strong) NSMutableDictionary *queueCache;



@end

@implementation WHTableViewController




- (void)viewDidLoad {
    [super viewDidLoad];
        [self loadData];
}

/**
 *  加载网络数据
 */
-(void)loadData
{
    NSString *urlString = @"https://raw.githubusercontent.com/yinqiaoyin/SimpleDemo/master/apps.json";
    
    //网络请求管理器
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"成功%@",[NSThread currentThread]);
        
        NSLog(@"%@,%@",responseObject,[responseObject class]);
        
        //MARK:字典转模型
        //创建数组接收网络数据
        NSArray *array = [responseObject copy];
        
        for (NSDictionary *dict in array) {
            
            //取到responseObject数组 进行 模型转换
            WHAppInfo *info = [[WHAppInfo alloc]init];
            [info setValuesForKeysWithDictionary:dict];
            [self.appInfos addObject:info];
        }
        
        NSLog(@"%@",self.appInfos);
        //从网络取完数据，可能已经晚了一段时间了，应该重新加载一下数据
        [self.tableView reloadData];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"失败%@",[NSThread currentThread]);
    }];
}

#pragma mark - 数据源方法

//某一组有多少行
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.appInfos.count;
}
//cell的内容
-(WHTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //取缓存池找
     WHTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    //设置数据
    WHAppInfo *info = self.appInfos[indexPath.row];
    cell.nameLabel.text = info.name;
    cell.downloadLabel.text = info.download;
    cell.iconView.image = nil;
    
    
    return cell;
}



#pragma mark - 懒加载
-(NSMutableArray *)appInfos
{
    if(_appInfos == nil)
    {
        _appInfos = [NSMutableArray array];
    }
    return _appInfos;
}


-(NSOperationQueue *)queue
{
    if(_queue == nil)
    {
        _queue = [NSOperationQueue new];
    }
    return _queue;
}

// 图片缓存的字典
- (NSMutableDictionary *)imageCache {
    if (_imageCache == nil) {
        _imageCache = [NSMutableDictionary dictionary];
    }
    return _imageCache;
}

// 操作的缓存
- (NSMutableDictionary *)queueCache {
    if (_queueCache == nil) {
        _queueCache = [NSMutableDictionary dictionary];
    }
    return _queueCache;
}

#pragma mark - 内存警告
/**
 * 收到内存警告:
 1. 将保存到内存中的图片清空
 - 如果图片保存到模型中的话,需要遍历模型数组,去给模型的image属性设置nil
 2. 将队列中的操作全部取消
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // 1. 清除掉内存中的image
//        for (int i=0; i<self.appInfos.count; i++) {
//            WHAppInfo *info = self.appInfos[i];
//            info.image = nil;
//        }
    [self.imageCache removeAllObjects];
    
    // 2. 取消掉队列中的所有操作，停止下载
    [self.queue cancelAllOperations];
    // 3. 移除所有的操作
    [self.queueCache removeAllObjects];
}


#pragma mark - 通过图片的址获取到缓存的路径

- (NSString *)cachePathWithUrlString:(NSString *)urlString {
    // 1. 如果取到caceh目录
    NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, true).firstObject;
    // 可能有问题
    // http://p16.qhimg.com/dr/48_48_/t0125e8d438ae9d2fbb.png
    // http://p16.baidu.com/dr/48_48_/t0125e8d438ae9d2fbb.png
    // 2. 取到文件名
    NSString *name = [urlString lastPathComponent];
    
    // 3. 拼接成结果 ()
    NSString *result = [cachePath stringByAppendingPathComponent:name];
    
    return result;
}



#pragma mark - 问题汇总
/**
 问题:
 1. 不能同步下载图片,不然会很卡
 - 在异步下载图片
 2. 图片下载完成之后,图片显示不出来
 - 原因: 返回cell的时候,图片可能还没有下载成功,而一返回cell的话,cell就被显示到界面上,这个时候还没有图片,图片下载成功之后给cell的imageView设置了图片,但是imageView没有大小.而当我一点击的时候,就会调用 layoutsubviews 的方法
 3. 如果在返回cell的时候,图片不清空,那么这个cell被复用的时候,会先显示之前的图标 ,然后才会显示当前cell对应的图标
 - 在返回cell的时候清空图片或者设置占位图片
 4. 如果后面的图片下载得慢,界面来回拖的时候,就会造成图片错乱,cell复用
 - 图片下载完成之后,将图片保存到模型中(图片与模型相对应,而不是与cell相对应,因为cell会复用)
 - 保存到模型中之后,就去刷新对应模型那一行的cell
 5. 把图片缓存到字典
 - 为什么: 缓存到字典里面在清除缓存的时候更加方式
 - 以后做缓存的话,请尽量考虑使用字典 NSCache(基于 LRU 算法)
 6. 如果图片下载需要10秒钟,我不停止的拖动cell,会造成什么样的情况??
 - 会一直初始化操作,一直给同一个图片下载添加多个操作,怎么解决?? 缓存操作
 */

@end
