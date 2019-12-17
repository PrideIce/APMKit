//
//  APMMonitor.h
//  Demo
//
//  Created by 陈逸辰 on 2019/12/15.
//  Copyright © 2019 陈逸辰. All rights reserved.

#define WHSingletonH() +(instancetype)sharedInstance;
#define WHSingletonM() static id _instance;\
+ (instancetype)sharedInstance {\
    static dispatch_once_t onceToken;\
    dispatch_once(&onceToken, ^{\
        _instance = [[self alloc] init];\
    });\
    return _instance;\
}

#import <Foundation/Foundation.h>

typedef void(^UpdateValueBlock)(float value);

@interface APMMonitor : NSObject

WHSingletonH()

- (void)startMonitoring;

- (void)stopMonitoring;

@property (nonatomic, copy) UpdateValueBlock valueBlock;

@end
