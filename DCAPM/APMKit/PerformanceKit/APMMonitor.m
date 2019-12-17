//
//  APMMonitor.m
//  Demo
//
//  Created by 陈逸辰 on 2019/12/15.
//  Copyright © 2019 陈逸辰. All rights reserved.

#import "APMMonitor.h"

@implementation APMMonitor {
    NSTimer *_timer;
}

WHSingletonM()

- (void)startMonitoring {
    [self stopMonitoring];
    _timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(updateValue) userInfo:nil repeats:YES];
    [_timer fire];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)updateValue {
    if (self.valueBlock) {
        self.valueBlock([self getValue]);
    }
}

- (float)getValue {
    return 0.0;
}

- (void)stopMonitoring {
    [_timer invalidate];
    _timer = nil;
}

@end
