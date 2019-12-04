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

@interface APMKit ()

@property (nonatomic,readwrite) BOOL displaying;

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
    [UIWindow initAPM];
}

- (void)enterMonitor
{
    self.displaying = YES;
    APMMonitorVC *vc = [[APMMonitorVC alloc] init];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:vc animated:YES completion:nil];
}

- (void)leaveMonitor
{
    self.displaying = NO;
}

@end
