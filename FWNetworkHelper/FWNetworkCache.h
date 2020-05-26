//
//  FWNetworkCache.h
//  FWNetworkHelper
//
//  Created by xfg on 2018/9/10.
//  Copyright © 2018年 xfg. All rights reserved.
//

/** ************************************************
 
 鸣谢：该库参考了PPNetworkHelper，在此特别鸣谢PPNetworkHelper作者。但由于本人项目中需
    要用到YY系列库（即：YYKit），因此与作者原库的只引入YYCache库的方式有冲突，同时也为了
    能够添加相关修改，因此便有了FWNetworkHelper；
 
 github地址：https://github.com/choiceyou/FWNetworkHelper
 bug反馈、交流群：670698309
 
 ***************************************************
 */


#import <Foundation/Foundation.h>

@interface FWNetworkCache : NSObject

/**
 异步缓存网络数据,根据请求的 URL与parameters
 做KEY存储数据, 这样就能缓存多级页面的数据

 @param httpData 服务器返回的数据
 @param URL 请求的URL地址
 @param parameters 请求的参数
 */
+ (void)setHttpCache:(id)httpData URL:(NSString *)URL parameters:(id)parameters;

/**
 根据请求的 URL与parameters 同步取出缓存数据

 @param URL 请求的URL
 @param parameters 请求的参数
 @return 缓存的服务器数据
 */
+ (id)httpCacheForURL:(NSString *)URL parameters:(id)parameters;

/**
 获取网络缓存的总大小 bytes(字节)

 @return 大小
 */
+ (NSInteger)getAllHttpCacheSize;

/**
 删除所有网络缓存
 */
+ (void)removeAllHttpCache;

@end
