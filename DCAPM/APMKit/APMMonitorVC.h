//
//  APMMonitorVC.h
//  DCAPM
//
//  Created by 陈逸辰 on 2019/12/3.
//  Copyright © 2019 陈逸辰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APMBaseVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface APMMonitorVC : APMBaseVC

@property (nonatomic,copy) void(^expandBtnAction)(void);

+ (instancetype)shared;

+ (void)show;

+ (void)hide;

- (void)setExpandBtnTitle:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
