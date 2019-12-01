//
//  CrashKit.m
//  DCAPM
//
//  Created by 陈逸辰 on 2019/11/30.
//  Copyright © 2019 陈逸辰. All rights reserved.
//

#import "CrashKit.h"

NSString *APMCrashRecord = @"APMCrashRecord";

NSString *applicationDocumentsDirectory() {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

void UncaughtExceptionHandler(NSException *exception) {
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    NSString *time= [formatter stringFromDate:[NSDate date]];
    NSArray *arr = [exception callStackSymbols];
    NSString *symbols = [arr componentsJoinedByString:@"\n"];
    NSString *expStack = [NSString stringWithFormat:@"=============Crash Report=============\nTime: %@\nName: %@\nReason: %@\nCallStackSymbols:\n%@\n\n\n",time,name,reason,symbols];
    
//    NSString *filePath = [applicationDocumentsDirectory() stringByAppendingPathComponent:@"Exception.txt"];
//    NSLog(@"APM CrashKit FilePath: %@", filePath);
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
                              @"stack":expStack};
    [records addObject:expDict];
    [userDefault setObject:records forKey:APMCrashRecord];
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
