//
//  PerformanceKit.h
//  APM
//
//  Created by 陈逸辰 on 2019/12/15.
//  Copyright © 2019 陈逸辰. All rights reserved.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, APMType) {
    APMTypeFPS    = 1 << 0,
    APMTypeCPU    = 1 << 1,
    APMTypeMemory = 1 << 2,
    APMTypeAll    = (APMTypeFPS | APMTypeCPU | APMTypeMemory)
};

@interface PerformanceKit : NSObject

/** switch on/off */
+ (void)toggleWith:(APMType)type;

+ (void)showWith:(APMType)type;

+ (void)hide;


































+ (instancetype)sharedInstance;

- (void)toggleWith:(APMType)type;

- (void)showWith:(APMType)type;

- (void)hide;

@end
