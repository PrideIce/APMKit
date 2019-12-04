//
//  CrashKit.m
//  DCAPM
//
//  Created by 陈逸辰 on 2019/11/30.
//  Copyright © 2019 陈逸辰. All rights reserved.
//

#import "CrashKit.h"
#import "CrashListVC.h"

NSString *APMCrashRecord = @"APMCrashRecord";

NSString *applicationDocumentsDirectory() {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

void UncaughtExceptionHandler(NSException *exception) {
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *time= [formatter stringFromDate:[NSDate date]];
    NSArray *arr = [exception callStackSymbols];
    NSString *expStack = [arr componentsJoinedByString:@"\n"];
    NSString *crashInfo = [NSString stringWithFormat:@"=============Crash Report=============\nTime: %@\nName: %@\nReason: %@\nCallStackSymbols:\n%@\n\n\n",time,name,reason,expStack];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSMutableArray *records = [userDefault arrayForKey:APMCrashRecord].mutableCopy;
    if (!records) {
        records = @[].mutableCopy;
    }
    NSDictionary *expDict = @{@"name":name,
                              @"reason":reason,
                              @"time":time,
                              @"crashInfo":crashInfo};
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

+ (void)enterCrashReport
{
//    CrashListVC *vc = [[CrashListVC alloc] init];
//    [self.navigationController pushViewController:vc animated:YES];
}

+ (NSString *)getLogFilePath
{
    NSString *filePath = [applicationDocumentsDirectory() stringByAppendingPathComponent:@"Exception.txt"];
    return filePath;
}
 

@end
