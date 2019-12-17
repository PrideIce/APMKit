//
//  APMConsoleLabel.h
//  APM
//
//  Created by 陈逸辰 on 2019/12/15.
//  Copyright © 2019 陈逸辰. All rights reserved.

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, APMLabelType) {
    APMLabelTypeFPS,     
    APMLabelTypeMemory,
    APMLabelTypeCPU
};

@interface APMConsoleLabel : UILabel

- (void)updateLabelWith:(APMLabelType)labelType value:(float)value;

@end
