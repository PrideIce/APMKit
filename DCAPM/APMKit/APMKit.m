//
//  APMKit.m
//  DCAPM
//
//  Created by 陈逸辰 on 2019/12/3.
//  Copyright © 2019 陈逸辰. All rights reserved.
//

#import "APMKit.h"
#import "APMMonitorVC.h"
#import "UIWindow+APM.h"
#import "PerformanceKit.h"
#import "CustomHTTPProtocol.h"

@interface APMKit ()

@property (nonatomic,readwrite) BOOL displaying;
@property (nonatomic,readwrite) BOOL isOpen;

@end

@implementation APMKit

+ (instancetype)shared
{
    static APMKit *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[APMKit alloc] init];
    });
    return instance;
}

+ (void)initAPM
{
    [UIWindow startAPM];
    
    BOOL close = [[NSUserDefaults standardUserDefaults] boolForKey:@"APM_Close_Status"];
    if (!close) {
        [APMKit startAPM];
    }
}

+ (void)startAPM
{
    [CrashKit startMonitor];
    
    [CustomHTTPProtocol start];
    
    APMKit.shared.isOpen = YES;
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"APM_Close_Status"];
}

+ (void)stopAPM
{
    //[CrashKit startMonitor];
    
    [CustomHTTPProtocol stop];
    
    [PerformanceKit hide];
    
    APMKit.shared.isOpen = NO;
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"APM_Close_Status"];
}

@end
