//
//  APMKit.h
//  DCAPM
//
//  Created by 陈逸辰 on 2019/12/3.
//  Copyright © 2019 陈逸辰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APMURLProtocol.h"
#import "CrashKit.h"
#import "APMMonitorVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface APMKit : NSObject

@property (nonatomic,readonly) BOOL isOpen;

+ (instancetype)shared;

+ (void)initAPM;

+ (void)startAPM;

+ (void)stopAPM;

@end

NS_ASSUME_NONNULL_END
