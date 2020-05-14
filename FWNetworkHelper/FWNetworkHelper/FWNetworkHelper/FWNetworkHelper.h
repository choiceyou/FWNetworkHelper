//
//  FWNetworkHelper.h
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
#import <UIKit/UIKit.h>
#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "FWNetworkCache.h"

/**
 设置请求数据
 
 - FWRequestSerializerJSON: JSON格式
 - FWRequestSerializerHTTP: 二进制格式
 */
typedef NS_ENUM(NSUInteger, FWRequestSerializer)
{
    FWRequestSerializerJSON,
    FWRequestSerializerHTTP,
};

/**
 设置响应数据
 
 - FWResponseSerializerJSON: JSON格式
 - FWResponseSerializerHTTP: 二进制格式
 */
typedef NS_ENUM(NSUInteger, FWResponseSerializer)
{
    FWResponseSerializerJSON,
    FWResponseSerializerHTTP,
};

/// 请求成功的Block
typedef void(^FWHttpRequestSuccess)(id responseObject);

/// 请求失败的Block
typedef void(^FWHttpRequestFailed)(id error);

/// 缓存的Block
typedef void(^FWHttpRequestCache)(id responseCacheObject);

/// 上传或者下载的进度, Progress.completedUnitCount:当前大小 - Progress.totalUnitCount:总大小
typedef void (^FWHttpProgress)(NSProgress *progress);


@interface FWNetworkHelper : NSObject

/// 取消指定URL的HTTP请求
+ (void)cancelRequestWithURL:(NSString *)URL;

/// 取消所有HTTP请求
+ (void)cancelAllRequest;


/**
 GET请求,无缓存
 
 @param URL 请求地址
 @param parameters 请求参数
 @param success 请求成功的回调
 @param failure 请求失败的回调
 @return 返回的对象可取消请求,调用cancel方法
 */
+ (__kindof NSURLSessionTask *)GET:(NSString *)URL
                        parameters:(id)parameters
                           headers:(NSDictionary *)headers
                           success:(FWHttpRequestSuccess)success
                           failure:(FWHttpRequestFailed)failure;

/**
 GET请求,可缓存
 
 @param URL 请求地址
 @param parameters 请求参数
 @param isShouldCache YES：启用缓存
 @param responseCache 缓存数据的回调，注意：这边如果传入nil，则表示不使用缓存
 @param success 请求成功的回调
 @param failure 请求失败的回调
 @return 返回的对象可取消请求,调用cancel方法
 */
+ (__kindof NSURLSessionTask *)GET:(NSString *)URL
                        parameters:(id)parameters
                           headers:(NSDictionary *)headers
                     isShouldCache:(BOOL)isShouldCache
                     responseCache:(FWHttpRequestCache)responseCache
                           success:(FWHttpRequestSuccess)success
                           failure:(FWHttpRequestFailed)failure;

/**
 POST请求,无缓存
 
 @param URL 请求地址
 @param parameters 请求参数
 @param success 请求成功的回调
 @param failure 请求失败的回调
 @return 返回的对象可取消请求,调用cancel方法
 */
+ (__kindof NSURLSessionTask *)POST:(NSString *)URL
                         parameters:(id)parameters
                            headers:(NSDictionary *)headers
                            success:(FWHttpRequestSuccess)success
                            failure:(FWHttpRequestFailed)failure;

/**
 POST请求,可缓存

 @param URL 请求地址
 @param parameters 请求参数
 @param isShouldCache YES：启用缓存
 @param responseCache 缓存数据的回调，注意：这边如果传入nil，则表示不使用缓存
 @param success 请求成功的回调
 @param failure 请求失败的回调
 @return 返回的对象可取消请求,调用cancel方法
 */
+ (__kindof NSURLSessionTask *)POST:(NSString *)URL
                         parameters:(id)parameters
                            headers:(NSDictionary *)headers
                      isShouldCache:(BOOL)isShouldCache
                      responseCache:(FWHttpRequestCache)responseCache
                            success:(FWHttpRequestSuccess)success
                            failure:(FWHttpRequestFailed)failure;

/**
 上传文件

 @param URL 请求地址
 @param parameters 请求参数
 @param name 文件对应服务器上的字段
 @param filePath 文件本地的沙盒路径
 @param progress 上传进度信息
 @param success 请求成功的回调
 @param failure 请求失败的回调
 @return 返回的对象可取消请求,调用cancel方法
 */
+ (__kindof NSURLSessionTask *)uploadFileWithURL:(NSString *)URL
                                      parameters:(id)parameters
                                         headers:(NSDictionary *)headers
                                            name:(NSString *)name
                                        filePath:(NSString *)filePath
                                        progress:(FWHttpProgress)progress
                                         success:(FWHttpRequestSuccess)success
                                         failure:(FWHttpRequestFailed)failure;

/**
 上传单/多张图片

 @param URL 请求地址
 @param parameters 请求参数
 @param name 图片对应服务器上的字段
 @param images 图片数组
 @param fileNames 图片文件名数组, 可以为nil, 数组内的文件名默认为当前日期时间"yyyyMMddHHmmss"
 @param imageScale 图片文件压缩比 范围 (0.f ~ 1.f)
 @param imageType 图片文件的类型,例:png、jpg(默认类型)....
 @param progress 上传进度信息
 @param success 请求成功的回调
 @param failure 请求失败的回调
 @return 返回的对象可取消请求,调用cancel方法
 */
+ (__kindof NSURLSessionTask *)uploadImagesWithURL:(NSString *)URL
                                        parameters:(id)parameters
                                           headers:(NSDictionary *)headers
                                              name:(NSString *)name
                                            images:(NSArray<UIImage *> *)images
                                         fileNames:(NSArray<NSString *> *)fileNames
                                        imageScale:(CGFloat)imageScale
                                         imageType:(NSString *)imageType
                                          progress:(FWHttpProgress)progress
                                           success:(FWHttpRequestSuccess)success
                                           failure:(FWHttpRequestFailed)failure;

/**
 下载文件

 @param URL 请求地址
 @param fileDir 文件存储目录(默认存储目录为Download)
 @param progress 文件下载的进度信息
 @param success 下载成功的回调(回调参数filePath:文件的路径)
 @param failure 下载失败的回调
 @return 返回NSURLSessionDownloadTask实例，可用于暂停继续，暂停调用suspend方法，开始下载调用resume方法
 */
+ (__kindof NSURLSessionTask *)downloadWithURL:(NSString *)URL
                                       fileDir:(NSString *)fileDir
                                      progress:(FWHttpProgress)progress
                                       success:(void(^)(NSString *filePath))success
                                       failure:(FWHttpRequestFailed)failure;


/*
 **************************************  说明  **********************************************
 *
 * 在一开始设计接口的时候就想着方法接口越少越好,越简单越好,只有GET,POST,上传,下载,监测网络状态就够了.
 *
 * 无奈的是在实际开发中,每个APP与后台服务器的数据交互都有不同的请求格式,如果要修改请求格式,就要在此封装
 * 内修改,再加上此封装在支持CocoaPods后,如果使用者pod update最新PPNetworkHelper,那又要重新修改此
 * 封装内的相关参数.
 *
 * 依个人经验,在项目的开发中,一般都会将网络请求部分封装 2~3 层,第2层配置好网络请求工具的在本项目中的各项
 * 参数,其暴露出的方法接口只需留出请求URL与参数的入口就行,第3层就是对整个项目请求API的封装,其对外暴露出的
 * 的方法接口只留出请求参数的入口.这样如果以后项目要更换网络请求库或者修改请求URL,在单个文件内完成配置就好
 * 了,大大降低了项目的后期维护难度
 *
 * 综上所述,最终还是将设置参数的接口暴露出来,如果通过CocoaPods方式使用PPNetworkHelper,在设置项目网络
 * 请求参数的时候,强烈建议开发者在此基础上再封装一层,通过以下方法配置好各种参数与请求的URL,便于维护
 *
 **************************************  说明  **********************************************
 */

#pragma mark - 设置AFHTTPSessionManager相关属性
#pragma mark 注意: 因为全局只有一个AFHTTPSessionManager实例,所以以下设置方式全局生效

/**
 在开发中,如果以下的设置方式不满足项目的需求,就调用此方法获取AFHTTPSessionManager实例进行自定义设置
 (注意: 调用此方法时在要导入AFNetworking.h头文件,否则可能会报找不到AFHTTPSessionManager的❌)

 @param sessionManager AFHTTPSessionManager的实例
 */
+ (void)setAFHTTPSessionManagerProperty:(void(^)(AFHTTPSessionManager *sessionManager))sessionManager;

/**
 设置网络请求参数的格式:默认为二进制格式

 @param requestSerializer PPRequestSerializerJSON(JSON格式),PPRequestSerializerHTTP(二进制格式)
 */
+ (void)setRequestSerializer:(FWRequestSerializer)requestSerializer;

/**
 设置服务器响应数据格式:默认为JSON格式

 @param responseSerializer PPResponseSerializerJSON(JSON格式),PPResponseSerializerHTTP(二进制格式)
 */
+ (void)setResponseSerializer:(FWResponseSerializer)responseSerializer;

/**
 设置请求超时时间:默认为30S

 @param time 时长
 */
+ (void)setRequestTimeoutInterval:(NSTimeInterval)time;

/**
 设置请求头

 @param value value
 @param field field
 */
+ (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field;

/**
 是否打开网络状态转圈菊花:默认打开

 @param open YES(打开), NO(关闭)
 */
+ (void)openNetworkActivityIndicator:(BOOL)open;

/**
 配置自建证书的Https请求, 参考链接: http://blog.csdn.net/syg90178aw/article/details/52839103

 @param cerPath 自建Https证书的路径
 @param validatesDomainName 是否需要验证域名，默认为YES. 如果证书的域名与请求的域名不一致，需设置为NO; 即服务器使用其他可信任机构颁发的证书，也可以建立连接，这个非常危险, 建议打开.validatesDomainName=NO, 主要用于这种情况:客户端请求的是子域名, 而证书上的是另外一个域名。因为SSL证书上的域名是独立的,假如证书上注册的域名是www.google.com, 那么mail.google.com是无法验证通过的.
 */
+ (void)setSecurityPolicyWithCerPath:(NSString *)cerPath validatesDomainName:(BOOL)validatesDomainName;

@end
