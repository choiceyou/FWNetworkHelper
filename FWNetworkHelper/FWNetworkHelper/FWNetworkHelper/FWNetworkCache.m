//
//  FWNetworkCache.m
//  FWNetworkHelper
//
//  Created by xfg on 2018/9/10.
//  Copyright © 2018年 xfg. All rights reserved.
//

#import "FWNetworkCache.h"
#import "YYKit.h"

static NSString *const kFWNetworkResponseCache = @"kFWNetworkResponseCache";

@implementation FWNetworkCache

static YYCache *_dataCache;

+ (void)initialize
{
    _dataCache = [YYCache cacheWithName:kFWNetworkResponseCache];
}

+ (void)setHttpCache:(id)httpData URL:(NSString *)URL parameters:(NSDictionary *)parameters
{
    NSString *cacheKey = [self cacheKeyWithURL:URL parameters:parameters];
    // 异步缓存,不会阻塞主线程
    [_dataCache setObject:httpData forKey:cacheKey withBlock:nil];
}

+ (id)httpCacheForURL:(NSString *)URL parameters:(NSDictionary *)parameters
{
    NSString *cacheKey = [self cacheKeyWithURL:URL parameters:parameters];
    return [_dataCache objectForKey:cacheKey];
}

+ (NSInteger)getAllHttpCacheSize
{
    return [_dataCache.diskCache totalCost];
}

+ (void)removeAllHttpCache
{
    [_dataCache.diskCache removeAllObjects];
}

+ (NSString *)cacheKeyWithURL:(NSString *)URL parameters:(NSDictionary *)parameters
{
    if(!parameters || parameters.count == 0){return URL;};
    // 将参数字典转换成字符串
    NSData *stringData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    NSString *paraString = [[NSString alloc] initWithData:stringData encoding:NSUTF8StringEncoding];
    return [NSString stringWithFormat:@"%@%@",URL,paraString];
}

@end
