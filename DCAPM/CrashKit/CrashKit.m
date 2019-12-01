//
//  CrashKit.m
//  DCAPM
//
//  Created by 陈逸辰 on 2019/11/30.
//  Copyright © 2019 陈逸辰. All rights reserved.
//

#import "CrashKit.h"
//#define APMCrashRecord @"APMCrashRecord"
const NSString *APMCrashRecord = @"APMCrashRecord";

NSString *applicationDocumentsDirectory() {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

void UncaughtExceptionHandler(NSException *exception) {
    NSArray *arr = [exception callStackSymbols];
    NSString *symbols = [arr componentsJoinedByString:@"\n"];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    NSString *time = [NSString stringWithFormat:@"%@", [NSDate date]];

    NSString *expStack = [NSString stringWithFormat:@"=============Crash Report=============\nTime: %@\nName: %@\nReason: %@\nCallStackSymbols:\n%@\n\n\n",time,name,reason,symbols];
    
    NSString *filePath = [applicationDocumentsDirectory() stringByAppendingPathComponent:@"Exception.txt"];
    NSLog(@"APM CrashKit FilePath: %@", filePath);
    
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    if (![fileManager fileExistsAtPath:filePath])
//    {
//        [fileManager createFileAtPath:filePath contents:nil attributes:nil];
//    }
//
//    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
//    [fileHandle seekToEndOfFile];
//    NSData *expData = [expStack dataUsingEncoding:NSUTF8StringEncoding];
//    [fileHandle writeData:expData]; //追加写入数据
//    [fileHandle closeFile];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSMutableArray *records = [userDefault arrayForKey:APMCrashRecord].mutableCopy;
    if (!records) {
        records = @[].mutableCopy;
    }
    NSDictionary *expDict = @{@"name":name,
                              @"reason":reason,
                              @"time":time,
                              @"symbols":symbols};
    [records addObject:expDict];
    [userDefault setObject:records forKey:APMCrashRecord];
//    [expStack writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

@implementation CrashKit

+ (void)load
{
    [CrashKit setDefaultHandler];
}

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}
   
+ (void)setDefaultHandler
{
     NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
}
   
+ (NSUncaughtExceptionHandler *)getHandler
{
     return NSGetUncaughtExceptionHandler();
}

+ (NSString *)getLogFilePath
{
    NSString *filePath = [applicationDocumentsDirectory() stringByAppendingPathComponent:@"Exception.txt"];
    return filePath;
}
 

@end
