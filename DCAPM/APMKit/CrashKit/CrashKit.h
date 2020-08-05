//
//  CrashKit.h
//  DCAPM
//
//  Created by 陈逸辰 on 2019/11/30.
//  Copyright © 2019 陈逸辰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CrashKit : NSObject

+ (void)startMonitor;

+ (NSUncaughtExceptionHandler *)getHandler;

+ (NSArray *)getAllCrashRecords;

+ (UIImage *)getScreenShot;

@end

NS_ASSUME_NONNULL_END
