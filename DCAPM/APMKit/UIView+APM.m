//
//  UIView+APM.m
//  DCAPM
//
//  Created by 陈逸辰 on 2019/12/4.
//  Copyright © 2019 陈逸辰. All rights reserved.
//

#import "UIView+APM.h"

@implementation UIView (APM)

- (BOOL)findAndResignFirstResponder
{
    if (self.isFirstResponder) {
        [self resignFirstResponder];
        return YES;
    }
    
    for (UIView *subView in self.subviews) {
        if ([subView findAndResignFirstResponder]) {
            return YES;
        }
    }
    
    return NO;
}

@end
