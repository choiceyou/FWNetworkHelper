//
//  FWNetworkHelper.m
//  FWNetworkHelper
//
//  Created by xfg on 2018/9/10.
//  Copyright © 2018年 xfg. All rights reserved.
//

#import "FWNetworkHelper.h"

#define FNSStringFormat(format,...) [NSString stringWithFormat:format,##__VA_ARGS__]

@implementation FWNetworkHelper

static NSMutableArray *_allSessionTask;
static AFHTTPSessionManager *_sessionManager;

#pragma mark -
#pragma mark - GET请求

+ (NSURLSessionTask *)GET:(NSString *)URL
               parameters:(id)parameters
                  headers:(NSDictionary *)headers
                  success:(FWHttpRequestSuccess)success
                  failure:(FWHttpRequestFailed)failure
{
    return [self GET:URL parameters:parameters headers:headers isShouldCache:NO responseCache:nil success:success failure:failure];
}

+ (__kindof NSURLSessionTask *)GET:(NSString *)URL
                        parameters:(id)parameters
                           headers:(NSDictionary *)headers
                     isShouldCache:(BOOL)isShouldCache
                     responseCache:(FWHttpRequestCache)responseCache
                           success:(FWHttpRequestSuccess)success
                           failure:(FWHttpRequestFailed)failure
{
    // 读取缓存
    (isShouldCache && responseCache!=nil) ? responseCache([FWNetworkCache httpCacheForURL:URL parameters:parameters]) : nil;
    
    NSURLSessionTask *sessionTask = [_sessionManager GET:URL parameters:parameters headers:headers progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [[self allSessionTask] removeObject:task];
        success ? success(responseObject) : nil;
        //对数据进行异步缓存
        (isShouldCache && responseCache!=nil) ? [FWNetworkCache setHttpCache:responseObject URL:URL parameters:parameters] : nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[self allSessionTask] removeObject:task];
        failure ? failure(error) : nil;
    }];
    // 添加sessionTask到数组
    sessionTask ? [[self allSessionTask] addObject:sessionTask] : nil;
    return sessionTask;
}


#pragma mark -
#pragma mark - POST请求

+ (NSURLSessionTask *)POST:(NSString *)URL
                parameters:(id)parameters
                   headers:(NSDictionary *)headers
                   success:(FWHttpRequestSuccess)success
                   failure:(FWHttpRequestFailed)failure
{
    return [self POST:URL parameters:parameters headers:headers isShouldCache:NO responseCache:nil success:success failure:failure];
}

+ (__kindof NSURLSessionTask *)POST:(NSString *)URL
                         parameters:(id)parameters
                            headers:(NSDictionary *)headers
                      isShouldCache:(BOOL)isShouldCache
                      responseCache:(FWHttpRequestCache)responseCache
                            success:(FWHttpRequestSuccess)success
                            failure:(FWHttpRequestFailed)failure
{
    //读取缓存
    (isShouldCache && responseCache!=nil) ? responseCache([FWNetworkCache httpCacheForURL:URL parameters:parameters]) : nil;
    
    NSURLSessionTask *sessionTask = [_sessionManager POST:URL parameters:parameters headers:headers progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [[self allSessionTask] removeObject:task];
        success ? success(responseObject) : nil;
        //对数据进行异步缓存
        (isShouldCache && responseCache!=nil) ? [FWNetworkCache setHttpCache:responseObject URL:URL parameters:parameters] : nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[self allSessionTask] removeObject:task];
        failure ? failure(error) : nil;
    }];
    // 添加最新的sessionTask到数组
    sessionTask ? [[self allSessionTask] addObject:sessionTask] : nil ;
    return sessionTask;
}


#pragma mark -
#pragma mark - 上传文件

+ (NSURLSessionTask *)uploadFileWithURL:(NSString *)URL
                             parameters:(id)parameters
                                headers:(NSDictionary *)headers
                                   name:(NSString *)name
                               filePath:(NSString *)filePath
                               progress:(FWHttpProgress)progress
                                success:(FWHttpRequestSuccess)success
                                failure:(FWHttpRequestFailed)failure
{
    NSURLSessionTask *sessionTask = [_sessionManager POST:URL parameters:parameters headers:headers constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSError *error = nil;
        [formData appendPartWithFileURL:[NSURL URLWithString:filePath] name:name error:&error];
        (failure && error) ? failure(error) : nil;
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        //上传进度
        dispatch_sync(dispatch_get_main_queue(), ^{
            progress ? progress(uploadProgress) : nil;
        });
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [[self allSessionTask] removeObject:task];
        success ? success(responseObject) : nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[self allSessionTask] removeObject:task];
        failure ? failure(error) : nil;
    }];
    // 添加sessionTask到数组
    sessionTask ? [[self allSessionTask] addObject:sessionTask] : nil ;
    return sessionTask;
}


#pragma mark -
#pragma mark - 上传多张图片

+ (NSURLSessionTask *)uploadImagesWithURL:(NSString *)URL
                               parameters:(id)parameters
                                  headers:(NSDictionary *)headers
                                     name:(NSString *)name
                                   images:(NSArray<UIImage *> *)images
                                fileNames:(NSArray<NSString *> *)fileNames
                               imageScale:(CGFloat)imageScale
                                imageType:(NSString *)imageType
                                 progress:(FWHttpProgress)progress
                                  success:(FWHttpRequestSuccess)success
                                  failure:(FWHttpRequestFailed)failure
{
    NSURLSessionTask *sessionTask = [_sessionManager POST:URL parameters:parameters headers:headers constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        for (NSUInteger i = 0; i < images.count; i++) {
            // 图片经过等比压缩后得到的二进制文件
            CGFloat tmpMax = 1.f;
            CGFloat tmpMin = 0.f;
            CGFloat tmpImageScale = imageScale;
            tmpImageScale = MIN(tmpImageScale, tmpMax);
            tmpImageScale = MAX(tmpImageScale, tmpMin);
            NSData *imageData = UIImageJPEGRepresentation(images[i], tmpImageScale);
            // 默认图片的文件名, 若fileNames为nil就使用
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyyMMddHHmmss";
            NSString *str = [formatter stringFromDate:[NSDate date]];
            NSString *imageFileName = FNSStringFormat(@"%@%lu.%@", str, (unsigned long)i, imageType?:@"jpg");
            [formData appendPartWithFileData:imageData
                                        name:name
                                    fileName:fileNames ? FNSStringFormat(@"%@.%@", fileNames[i], imageType?:@"jpg") : imageFileName
                                    mimeType:FNSStringFormat(@"image/%@", imageType ?: @"jpg")];
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        //上传进度
        dispatch_sync(dispatch_get_main_queue(), ^{
            progress ? progress(uploadProgress) : nil;
        });
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [[self allSessionTask] removeObject:task];
        success ? success(responseObject) : nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[self allSessionTask] removeObject:task];
        failure ? failure(error) : nil;
    }];
    // 添加sessionTask到数组
    sessionTask ? [[self allSessionTask] addObject:sessionTask] : nil ;
    return sessionTask;
}


#pragma mark -
#pragma mark - 下载文件

+ (NSURLSessionTask *)downloadWithURL:(NSString *)URL
                              fileDir:(NSString *)fileDir
                             progress:(FWHttpProgress)progress
                              success:(void(^)(NSString *))success
                              failure:(FWHttpRequestFailed)failure
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URL]];
    __block NSURLSessionDownloadTask *downloadTask = [_sessionManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        //下载进度
        dispatch_sync(dispatch_get_main_queue(), ^{
            progress ? progress(downloadProgress) : nil;
        });
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        //拼接缓存目录
        NSString *downloadDir = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:fileDir ? fileDir : @"Download"];
        //打开文件管理器
        NSFileManager *fileManager = [NSFileManager defaultManager];
        //创建Download目录
        [fileManager createDirectoryAtPath:downloadDir withIntermediateDirectories:YES attributes:nil error:nil];
        //拼接文件路径
        NSString *filePath = [downloadDir stringByAppendingPathComponent:response.suggestedFilename];
        //返回文件位置的URL路径
        return [NSURL fileURLWithPath:filePath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        [[self allSessionTask] removeObject:downloadTask];
        if(failure && error) {failure(error) ; return ;};
        success ? success(filePath.absoluteString /** NSURL->NSString*/) : nil;
    }];
    //开始下载
    [downloadTask resume];
    // 添加sessionTask到数组
    downloadTask ? [[self allSessionTask] addObject:downloadTask] : nil ;
    return downloadTask;
}


#pragma mark -
#pragma mark - 取消请求

#pragma mark 取消所有请求
+ (void)cancelAllRequest
{
    // 锁操作
    @synchronized(self) {
        [[self allSessionTask] enumerateObjectsUsingBlock:^(NSURLSessionTask  *_Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            [task cancel];
        }];
        [[self allSessionTask] removeAllObjects];
    }
}

#pragma mark 取消请求
+ (void)cancelRequestWithURL:(NSString *)URL
{
    if (!URL) { return; }
    @synchronized (self) {
        [[self allSessionTask] enumerateObjectsUsingBlock:^(NSURLSessionTask  *_Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([task.currentRequest.URL.absoluteString hasPrefix:URL]) {
                [task cancel];
                [[self allSessionTask] removeObject:task];
                *stop = YES;
            }
        }];
    }
}

#pragma mark 取消请求
+ (void)cancelRequestWithTask:(NSURLSessionTask *)task
{
    if (!task) { return; }
    @synchronized (self) {
        [task cancel];
        if ([[self allSessionTask] containsObject:task]) {
            [[self allSessionTask] removeObject:task];
        }
    }
}


#pragma mark -
#pragma mark - Other

#pragma mark 存储着所有的请求task数组
+ (NSMutableArray *)allSessionTask
{
    if (!_allSessionTask) {
        _allSessionTask = [[NSMutableArray alloc] init];
    }
    return _allSessionTask;
}


#pragma mark -
#pragma mark - 初始化AFHTTPSessionManager相关属性

#pragma mark 开始监测网络状态
+ (void)load
{
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

#pragma mark 所有的HTTP请求共享一个AFHTTPSessionManager
+ (void)initialize
{
    _sessionManager = [AFHTTPSessionManager manager];
    _sessionManager.requestSerializer.timeoutInterval = 30.f;
    _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/plain", @"text/javascript", @"text/xml", @"image/*", nil];
    // 打开状态栏的等待菊花
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
}


#pragma mark -
#pragma mark - 重置AFHTTPSessionManager相关属性

+ (void)setAFHTTPSessionManagerProperty:(void (^)(AFHTTPSessionManager *))sessionManager
{
    sessionManager ? sessionManager(_sessionManager) : nil;
}

+ (void)setRequestSerializer:(FWRequestSerializer)requestSerializer
{
    _sessionManager.requestSerializer = requestSerializer==FWRequestSerializerHTTP ? [AFHTTPRequestSerializer serializer] : [AFJSONRequestSerializer serializer];
}

+ (void)setResponseSerializer:(FWResponseSerializer)responseSerializer
{
    _sessionManager.responseSerializer = responseSerializer==FWResponseSerializerHTTP ? [AFHTTPResponseSerializer serializer] : [AFJSONResponseSerializer serializer];
}

+ (void)setRequestTimeoutInterval:(NSTimeInterval)time
{
    _sessionManager.requestSerializer.timeoutInterval = time;
}

+ (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field
{
    [_sessionManager.requestSerializer setValue:value forHTTPHeaderField:field];
}

+ (void)openNetworkActivityIndicator:(BOOL)open
{
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:open];
}

+ (void)setSecurityPolicyWithCerPath:(NSString *)cerPath validatesDomainName:(BOOL)validatesDomainName
{
    NSData *cerData = [NSData dataWithContentsOfFile:cerPath];
    // 使用证书验证模式
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    // 如果需要验证自建证书(无效证书)，需要设置为YES
    securityPolicy.allowInvalidCertificates = YES;
    // 是否需要验证域名，默认为YES;
    securityPolicy.validatesDomainName = validatesDomainName;
    securityPolicy.pinnedCertificates = [[NSSet alloc] initWithObjects:cerData, nil];
    [_sessionManager setSecurityPolicy:securityPolicy];
}

@end
