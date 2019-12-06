//
//  CrashKit.m
//  DCAPM
//
//  Created by 陈逸辰 on 2019/11/30.
//  Copyright © 2019 陈逸辰. All rights reserved.
//

#import "CrashKit.h"
#import "CrashListVC.h"
#import "CrashModel.h"

NSString *APMCrashRecord = @"APMCrashRecord";

NSString *applicationDocumentsDirectory() {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

void UncaughtExceptionHandler(NSException *exception) {
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [NSDate date];
    NSString *timeStamp = [NSString stringWithFormat:@"%lld", (long long)([date timeIntervalSince1970] * 1000)];
    NSString *timeDate = [formatter stringFromDate:date];
    NSArray *arr = [exception callStackSymbols];
    NSString *expStack = [arr componentsJoinedByString:@"\n"];
    
    CrashModel *model = [[CrashModel alloc] init];
    model.name = name;
    model.reason = reason;
    model.timeDate = timeDate;
    model.timeStamp = timeStamp;
    model.stack = expStack;
    [model insertToDB];
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

+ (NSArray *)getAllCrashRecords
{
    return [CrashModel getAllRecords];
}
 

@end
