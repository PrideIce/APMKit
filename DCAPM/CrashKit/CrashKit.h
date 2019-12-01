//
//  CrashKit.h
//  DCAPM
//
//  Created by 陈逸辰 on 2019/11/30.
//  Copyright © 2019 陈逸辰. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CrashKit : NSObject

+ (NSString *)getLogFilePath;

+ (NSUncaughtExceptionHandler *)getHandler;

@end

NS_ASSUME_NONNULL_END
