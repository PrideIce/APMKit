//
//  APMURLProtocol.m
//  DCAPM
//
//  Created by 陈逸辰 on 2019/12/10.
//  Copyright © 2019 陈逸辰. All rights reserved.
//

#import "APMURLProtocol.h"
#import "APMURLSessionConfiguration.h"
#import "NetworkModel.h"

static NSString *const APMHTTP = @"APMHTTP";//为了避免canInitWithRequest和canonicalRequestForRequest的死循环

@interface APMURLProtocol ()

@property (nonatomic, strong) NSURLRequest *APM_request;
@property (nonatomic, strong) NSURLResponse *APM_response;
@property (nonatomic, strong) NSMutableData *APM_data;
@property (nonatomic, strong) NSError *APM_error;
@property (nonatomic, strong) NetworkModel *model;

@end

@implementation APMURLProtocol

#pragma mark - init
- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

//+ (void)load
//{
//}

+ (void)startMonitor
{
    APMURLSessionConfiguration *sessionConfiguration = [APMURLSessionConfiguration defaultConfiguration];
    [NSURLProtocol registerClass:[APMURLProtocol class]];
    if (![sessionConfiguration isSwizzle]) {
        [sessionConfiguration load];
    }
}

+ (void)endMonitor
{
    APMURLSessionConfiguration *sessionConfiguration = [APMURLSessionConfiguration defaultConfiguration];
    [NSURLProtocol unregisterClass:[APMURLProtocol class]];
    if ([sessionConfiguration isSwizzle]) {
        [sessionConfiguration unload];
    }
}

/**
 需要控制的请求

 @param request 此次请求
 @return 是否需要监控
 */
+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    if (![request.URL.scheme isEqualToString:@"http"] &&
        ![request.URL.scheme isEqualToString:@"https"]) {
        return NO;
    }
    //如果是已经拦截过的  就放行
    if ([NSURLProtocol propertyForKey:APMHTTP inRequest:request]) {
        return NO;
    }
    return YES;
}

/**
 设置我们自己的自定义请求
 可以在这里统一加上头之类的

 @param request 应用的此次请求
 @return 我们自定义的请求
 */
+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    NSMutableURLRequest *mutableReqeust = [request mutableCopy];
    [NSURLProtocol setProperty:@YES
                        forKey:APMHTTP
                     inRequest:mutableReqeust];
    return [mutableReqeust copy];
}

- (void)startLoading
{
    self.APM_request = self.request;
    self.model = [[NetworkModel alloc] init];
    self.model.request = self.request;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    self.model.requestTime = [formatter stringFromDate:[NSDate date]];
    
    NSURLSessionDataTask *sessionDataTask = [[NSURLSession sharedSession] dataTaskWithRequest:self.request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        //将获取的数据回传给外面的请求
        [self.client URLProtocol:self didLoadData:data];
        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        [self.client URLProtocol:self didFailWithError:error];
        [self.client URLProtocolDidFinishLoading:self];
        self.APM_data = data.mutableCopy;
        self.APM_response = response;
        self.APM_error = error;
        self.model.response = response.description;
        self.model.error = error.description;
    }];
    [sessionDataTask resume];
}

- (void)stopLoading
{
    //获取请求方法
    NSString *requestMethod = self.APM_request.HTTPMethod;
    NSLog(@"请求方法：%@\n", requestMethod);

    //获取请求头
    NSDictionary *headers = self.APM_request.allHTTPHeaderFields;
    NSLog(@"请求头：\n");
    for (NSString *key in headers.allKeys) {
        NSLog(@"%@ : %@", key, headers[key]);
    }
//    NSLog(@"%@", self.APM_request.description);
//    NSLog(@"%@", self.APM_response.description);
//    NSLog(@"%@", self.APM_error.description);
    //获取请求结果
    NSString *string = [self responseJSONFromData:self.APM_data];
    self.model.data = string;
    BOOL result = [self.model insertToDB];
//    NSLog(@"请求结果：%@", string);
}

//转换json
- (id)responseJSONFromData:(NSData *)data
{
    if (data == nil) return nil;
    NSError *error = nil;
    id returnValue = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error) {
        NSLog(@"JSON Parsing Error: %@", error);
        return nil;
    }

    if (!returnValue || returnValue == [NSNull null]) {
        return nil;
    }

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:returnValue options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return [self pureStr:jsonString];
}

- (NSString *)pureStr:(NSString *)rawString
{
    NSMutableString *mutStr = [NSMutableString stringWithString:rawString];
    NSRange range = {0,rawString.length};
    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@"\\" withString:@"" options:NSLiteralSearch range:range];
    return mutStr;
}

@end
