//
//  NSData+APM.m
//  DCAPM
//
//  Created by 陈逸辰 on 2019/12/12.
//  Copyright © 2019 陈逸辰. All rights reserved.
//

#import "NSData+APM.h"

@implementation NSData (APM)

//转换json
- (NSString *)jsonString
{
    if (self == nil) return nil;
    NSError *error = nil;
    id returnValue = [NSJSONSerialization JSONObjectWithData:self options:0 error:&error];
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
