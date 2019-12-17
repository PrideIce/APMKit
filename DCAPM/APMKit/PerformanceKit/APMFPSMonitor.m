//
//  APMFPSMonitor.m
//  Demo
//
//  Created by 陈逸辰 on 2019/12/15.
//  Copyright © 2019 陈逸辰. All rights reserved.

#import "APMFPSMonitor.h"

@interface APMFPSMonitor()

@property (nonatomic, strong) CADisplayLink *displayLink;

@property (nonatomic, assign) NSTimeInterval lastTimestamp;

@property (nonatomic, assign) NSInteger performTimes;

@end

@implementation APMFPSMonitor

WHSingletonM()

- (void)startMonitoring {
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkTicks:)];
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)displayLinkTicks:(CADisplayLink *)link {
    if (_lastTimestamp == 0) {
        _lastTimestamp = link.timestamp;
        return;
    }
    _performTimes ++;
    NSTimeInterval interval = link.timestamp - _lastTimestamp;
    if (interval < 1) { return; }
    _lastTimestamp = link.timestamp;
    float fps = _performTimes / interval;
    _performTimes = 0;
    if (self.valueBlock) {
        self.valueBlock(fps);
    }
}

- (void)stopMonitoring {
    [_displayLink invalidate];
}

@end
