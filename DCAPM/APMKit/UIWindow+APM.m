//
//  UIWindow+APM.m
//  DCAPM
//
//  Created by 陈逸辰 on 2019/12/4.
//  Copyright © 2019 陈逸辰. All rights reserved.
//

#import "UIWindow+APM.h"
#import <objc/runtime.h>
#import "APMMonitorVC.h"

@implementation UIWindow (APM)

+ (void)startAPM
{
    Class class = [UIWindow class];
    
    // When swizzling a class method, use the following:
    // Class class = object_getClass((id)self);
    
    SEL originalSelector = @selector(sendEvent:);
    SEL swizzledSelector = @selector(apm_sendEvent:);
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (void)apm_sendEvent:(UIEvent *)event
{
    if (event.type == UIEventTypeTouches) {
        if (event.allTouches.count == 3) {
            [self handleEvent:event];
        }
    }
    
    [self apm_sendEvent:event];
}

- (void)handleEvent:(UIEvent *)event
{
    BOOL allDown = YES;
    for (UITouch *touch in event.allTouches) {
        if ([touch locationInView:self].y <= [touch previousLocationInView:self].y) {
            allDown = NO;
        }
    }
    if (allDown) {
        [APMMonitorVC show];
    } else {
        [APMMonitorVC hide];
    }
}

@end
