//
//  APMKit.h
//  DCAPM
//
//  Created by 陈逸辰 on 2019/12/3.
//  Copyright © 2019 陈逸辰. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface APMKit : NSObject

+ (instancetype)shared;

+ (void)initAPM;

//@property (nonatomic,readonly) BOOL displaying;
//
//- (void)enterMonitor;
//
//- (void)leaveMonitor;

@end

NS_ASSUME_NONNULL_END
