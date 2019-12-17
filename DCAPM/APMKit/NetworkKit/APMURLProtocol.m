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

@interface APMURLProtocol ()<NSURLConnectionDelegate,NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSURLConnection *connection;

@property (nonatomic, strong) NSURLRequest *apm_request;
@property (nonatomic, strong) NSURLResponse *apm_response;
@property (nonatomic, strong) NSMutableData *apm_data;
@property (nonatomic, strong) NSError *apm_error;
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

- (void)startLoading {
    self.apm_request = self.request;
    self.model = [[NetworkModel alloc] init];
    self.model.request = self.request;
    self.model.startTime = [[NSDate date] timeIntervalSince1970];
    self.apm_data = [NSMutableData data];
    
    NSURLRequest *request = [[self class] canonicalRequestForRequest:self.request];
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

- (void)stopLoading {
   [self.connection cancel];
    
    self.model.url = self.request.URL.absoluteString;
    self.model.responseTime = [NSString stringWithFormat:@"%lld", (long long)([[NSDate date] timeIntervalSince1970] * 1000)];
    self.model.data = self.apm_data;
    self.model.response = (NSHTTPURLResponse *)self.apm_response;
    self.model.statusCode = self.model.response.statusCode;
    self.model.requestDataLength = [self dgm_getHeadersLengthWithCookie] + [self dgm_getBodyLength];
    self.model.totalDataLength = self.model.requestDataLength + self.model.data.length;
    
    [self.model insertToDB];
}

#pragma mark - NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [self.client URLProtocol:self didFailWithError:error];
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection{
    return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge{
    [self.client URLProtocol:self didReceiveAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection
didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [self.client URLProtocol:self didCancelAuthenticationChallenge:challenge];
}

#pragma mark - NSURLConnectionDataDelegate
-(NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response{
    if (response != nil) {
        self.apm_response = response;
        [self.client URLProtocol:self wasRedirectedToRequest:request redirectResponse:response];
    }
    return request;
}

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response {
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    self.apm_response = response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.client URLProtocol:self didLoadData:data];
    [self.apm_data appendData:data];
    NSLog(@"receiveData");
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return cachedResponse;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [[self client] URLProtocolDidFinishLoading:self];
}

#pragma mark - Cookie

- (NSUInteger)dgm_getHeadersLengthWithCookie {
    NSUInteger headersLength = 0;

    NSDictionary<NSString *, NSString *> *headerFields = self.apm_request.allHTTPHeaderFields;
    NSDictionary<NSString *, NSString *> *cookiesHeader = [self dgm_getCookies];

    // 添加 cookie 信息
    if (cookiesHeader.count) {
        NSMutableDictionary *headerFieldsWithCookies = [NSMutableDictionary dictionaryWithDictionary:headerFields];
        [headerFieldsWithCookies addEntriesFromDictionary:cookiesHeader];
        headerFields = [headerFieldsWithCookies copy];
    }
    NSLog(@"%@", headerFields);
    NSString *headerStr = @"";

    for (NSString *key in headerFields.allKeys) {
        headerStr = [headerStr stringByAppendingString:key];
        headerStr = [headerStr stringByAppendingString:@": "];
        if ([headerFields objectForKey:key]) {
            headerStr = [headerStr stringByAppendingString:headerFields[key]];
        }
        headerStr = [headerStr stringByAppendingString:@"\n"];
    }
    NSData *headerData = [headerStr dataUsingEncoding:NSUTF8StringEncoding];
    headersLength = headerData.length;
    return headersLength;
}

- (NSDictionary<NSString *, NSString *> *)dgm_getCookies {
    NSDictionary<NSString *, NSString *> *cookiesHeader;
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray<NSHTTPCookie *> *cookies = [cookieStorage cookiesForURL:self.request.URL];
    if (cookies.count) {
        cookiesHeader = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
    }
    return cookiesHeader;
}

#pragma mark - Body

- (NSUInteger)dgm_getBodyLength {
    NSDictionary<NSString *, NSString *> *headerFields = self.request.allHTTPHeaderFields;
    NSUInteger bodyLength = [self.request.HTTPBody length];

    if ([headerFields objectForKey:@"Content-Encoding"]) {
        NSData *bodyData;
        if (self.request.HTTPBody == nil) {
            uint8_t d[1024] = {0};
            NSInputStream *stream = self.request.HTTPBodyStream;
            NSMutableData *data = [[NSMutableData alloc] init];
            [stream open];
            while ([stream hasBytesAvailable]) {
                NSInteger len = [stream read:d maxLength:1024];
                if (len > 0 && stream.streamError == nil) {
                    [data appendBytes:(void *)d length:len];
                }
            }
            bodyData = [data copy];
            [stream close];
        } else {
            bodyData = self.request.HTTPBody;
        }
//        bodyLength = [[bodyData gzippedData] length];
        bodyLength = bodyData.length;
    }

    return bodyLength;
}

@end

//#import "APMURLProtocol.h"
//#import "APMURLSessionConfiguration.h"
//#import "NetworkModel.h"
//
//static NSString *const APMHTTP = @"APMHTTP";//为了避免canInitWithRequest和canonicalRequestForRequest的死循环
//
//@interface APMURLProtocol ()
//
//@property (nonatomic, strong) NSURLRequest *apm_request;
//@property (nonatomic, strong) NSURLResponse *apm_response;
//@property (nonatomic, strong) NSMutableData *apm_data;
//@property (nonatomic, strong) NSError *apm_error;
//@property (nonatomic, strong) NetworkModel *model;
//
//@end
//
//@implementation APMURLProtocol
//
//#pragma mark - init
//- (instancetype)init
//{
//    self = [super init];
//    if (self) {
//    }
//    return self;
//}
//
////+ (void)load
////{
////}
//
//+ (void)startMonitor
//{
//    APMURLSessionConfiguration *sessionConfiguration = [APMURLSessionConfiguration defaultConfiguration];
//    [NSURLProtocol registerClass:[APMURLProtocol class]];
//    if (![sessionConfiguration isSwizzle]) {
//        [sessionConfiguration load];
//    }
//}
//
//+ (void)endMonitor
//{
//    APMURLSessionConfiguration *sessionConfiguration = [APMURLSessionConfiguration defaultConfiguration];
//    [NSURLProtocol unregisterClass:[APMURLProtocol class]];
//    if ([sessionConfiguration isSwizzle]) {
//        [sessionConfiguration unload];
//    }
//}
//
///**
// 需要控制的请求
//
// @param request 此次请求
// @return 是否需要监控
// */
//+ (BOOL)canInitWithRequest:(NSURLRequest *)request
//{
//    if (![request.URL.scheme isEqualToString:@"http"] &&
//        ![request.URL.scheme isEqualToString:@"https"]) {
//        return NO;
//    }
//    //如果是已经拦截过的  就放行
//    if ([NSURLProtocol propertyForKey:APMHTTP inRequest:request]) {
//        return NO;
//    }
//    return YES;
//}
//
///**
// 设置我们自己的自定义请求
// 可以在这里统一加上头之类的
//
// @param request 应用的此次请求
// @return 我们自定义的请求
// */
//+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
//{
//    NSMutableURLRequest *mutableReqeust = [request mutableCopy];
//    [NSURLProtocol setProperty:@YES
//                        forKey:APMHTTP
//                     inRequest:mutableReqeust];
//    return [mutableReqeust copy];
//}
//
//- (void)startLoading
//{
//    self.apm_request = self.request;
//    self.model = [[NetworkModel alloc] init];
//    self.model.request = self.request;
//    self.model.startTime = [[NSDate date] timeIntervalSince1970];
//
//    NSURLSessionDataTask *sessionDataTask = [[NSURLSession sharedSession] dataTaskWithRequest:self.request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        //将获取的数据回传给外面的请求
//        [self.client URLProtocol:self didLoadData:data];
//        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
//        [self.client URLProtocol:self didFailWithError:error];
//        [self.client URLProtocolDidFinishLoading:self];
//        self.apm_data = data.mutableCopy;
//        self.apm_response = response;
//        self.apm_error = error;
//        self.model.response = (NSHTTPURLResponse *)response;
//        self.model.error = error.description;
//        self.model.responseTime = [NSString stringWithFormat:@"%lld", (long long)([[NSDate date] timeIntervalSince1970] * 1000)];
//    }];
//    [sessionDataTask resume];
//}
//
//- (void)stopLoading
//{
//    //获取请求方法
////    NSString *requestMethod = self.apm_request.HTTPMethod;
////    NSLog(@"请求方法：%@\n", requestMethod);
////
////    //获取请求头
////    NSDictionary *headers = self.apm_request.allHTTPHeaderFields;
////    NSLog(@"请求头：\n");
////    for (NSString *key in headers.allKeys) {
////        NSLog(@"%@ : %@", key, headers[key]);
////    }
////    NSLog(@"%@", self.apm_request.description);
////    NSLog(@"%@", self.apm_response.description);
////    NSLog(@"%@", self.apm_error.description);
//    self.model.totalDuration = [NSString stringWithFormat:@"%fs",[[NSDate date] timeIntervalSince1970] - self.model.startTime];
//    //获取请求结果
////    NSString *string = [self responseJSONFromData:self.apm_data];
//    self.model.data = self.apm_data;
//    [self.model insertToDB];
////    NSLog(@"请求结果：%@", string);
//}
//
////转换json
//- (id)responseJSONFromData:(NSData *)data
//{
//    if (data == nil) return nil;
//    NSError *error = nil;
//    id returnValue = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
//    if (error) {
//        NSLog(@"JSON Parsing Error: %@", error);
//        return nil;
//    }
//
//    if (!returnValue || returnValue == [NSNull null]) {
//        return nil;
//    }
//
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:returnValue options:NSJSONWritingPrettyPrinted error:nil];
//    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//    return [self pureStr:jsonString];
//}
//
//- (NSString *)pureStr:(NSString *)rawString
//{
//    NSMutableString *mutStr = [NSMutableString stringWithString:rawString];
//    NSRange range = {0,rawString.length};
//    //去掉字符串中的空格
//    [mutStr replaceOccurrencesOfString:@"\\" withString:@"" options:NSLiteralSearch range:range];
//    return mutStr;
//}
//
//@end
