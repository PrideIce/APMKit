//
//  PerformanceKit.m
//  APM
//
//  Created by 陈逸辰 on 2019/12/15.
//  Copyright © 2019 陈逸辰. All rights reserved.

#import "PerformanceKit.h"
#import "APMFPSMonitor.h"
#import "APMCpuMonitor.h"
#import "APMMemoryMonitor.h"
#import "APMConsoleLabel.h"
#import "APMTempVC.h"
#import "APMMacro.h"

static NSInteger const kDebugLabelWidth = 70;
static NSInteger const kDebugLabelHeight = 20;
static NSInteger const KDebugMargin = 20;

@interface PerformanceKit()
@property (nonatomic, assign) BOOL isShowing;
@property(nonatomic, strong) UIWindow *debugWindow;
@property (nonatomic, strong) APMConsoleLabel *memoryLabel;
@property (nonatomic, strong) APMConsoleLabel *fpsLabel;
@property (nonatomic, strong) APMConsoleLabel *cpuLabel;
@end

@implementation PerformanceKit

static id _instance;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

#pragma mark - Class function

+ (void)toggleWith:(APMType)type {
    [[self sharedInstance] toggleWith:type];
}

+ (void)showWith:(APMType)type {
    [[self sharedInstance] showWith:type];
}

+ (void)hide {
    [[self sharedInstance] hide];
}

#pragma mark - Show with type

- (void)toggleWith:(APMType)type {
    if (self.isShowing) {
        [self hide];
    } else {
        [self showWith:type];
    }
}

- (void)showWith:(APMType)type {
    [self clearUp];
    [self setDebugWindow];
    
    if (type & APMTypeFPS) {
        [self showFPS];
    }
    
    if (type & APMTypeMemory) {
        [self showMemory];
    }
    
    if (type & APMTypeCPU) {
        [self showCPU];
    }
}

#pragma mark - Window

- (void)setDebugWindow {
    CGFloat debugWindowY = APMIphoneXScreen ? 30 : 0;
    self.debugWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, debugWindowY, APMScreenWidth, kDebugLabelHeight)];
    self.debugWindow.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    self.debugWindow.windowLevel = UIWindowLevelAlert;
    self.debugWindow.rootViewController = [APMTempVC new];
    self.debugWindow.hidden = NO;
}

#pragma mark - Show

- (void)showFPS {
    [[APMFPSMonitor sharedInstance] startMonitoring];
    [APMFPSMonitor sharedInstance].valueBlock = ^(float value) {
        [self.fpsLabel updateLabelWith:APMLabelTypeFPS value:value];
    };
    [self show:self.fpsLabel];
}

- (void)showMemory {
    [[APMMemoryMonitor sharedInstance] startMonitoring];
    [APMMemoryMonitor sharedInstance].valueBlock = ^(float value) {
        [self.memoryLabel updateLabelWith:APMLabelTypeMemory value:value];
    };
    [self show:self.memoryLabel];
}

- (void)showCPU {
    [[APMCpuMonitor sharedInstance] startMonitoring];
    [APMCpuMonitor sharedInstance].valueBlock = ^(float value) {
        [self.cpuLabel updateLabelWith:APMLabelTypeCPU value:value];
    };
    [self show:self.cpuLabel];
}

- (void)show:(APMConsoleLabel *)consoleLabel {
    [self.debugWindow addSubview:consoleLabel];
    CGRect consoleLabelFrame = CGRectZero;
    if (consoleLabel == self.cpuLabel) {
        consoleLabelFrame = CGRectMake((APMScreenWidth - kDebugLabelWidth) / 2, 0, kDebugLabelWidth, kDebugLabelHeight);
    } else if (consoleLabel == self.fpsLabel) {
        consoleLabelFrame = CGRectMake(APMScreenWidth - kDebugLabelWidth - KDebugMargin, 0, kDebugLabelWidth, kDebugLabelHeight);
    } else {
        consoleLabelFrame = CGRectMake(KDebugMargin, 0, kDebugLabelWidth, kDebugLabelHeight);
    }
    [UIView animateWithDuration:0.3 animations:^{
        consoleLabel.frame = consoleLabelFrame;
    } completion:^(BOOL finished) {
        self.isShowing = YES;
    }];
}

#pragma mark - Hide

- (void)hide {
    [UIView animateWithDuration:0.3 animations:^{
        self.cpuLabel.frame = CGRectMake((APMScreenWidth - kDebugLabelWidth) / 2, -kDebugLabelHeight, kDebugLabelWidth, kDebugLabelHeight);
        self.memoryLabel.frame = CGRectMake(-kDebugLabelWidth, 0, kDebugLabelWidth, kDebugLabelHeight);
        self.fpsLabel.frame = CGRectMake(APMScreenWidth + kDebugLabelWidth, 0, kDebugLabelWidth, kDebugLabelHeight);
    } completion:^(BOOL finished) {
        [self clearUp];
    }];
}

#pragma mark - Clear

- (void)clearUp {
    [[APMFPSMonitor sharedInstance] stopMonitoring];
    [[APMMemoryMonitor sharedInstance] stopMonitoring];
    [[APMCpuMonitor sharedInstance] stopMonitoring];
    [self.fpsLabel removeFromSuperview];
    [self.memoryLabel removeFromSuperview];
    [self.cpuLabel removeFromSuperview];
    self.debugWindow.hidden = YES;
    self.fpsLabel = nil;
    self.memoryLabel = nil;
    self.cpuLabel = nil;
    self.debugWindow = nil;
    self.isShowing = NO;
}

#pragma mark - Label

- (APMConsoleLabel *)memoryLabel {
    if (!_memoryLabel) {
        _memoryLabel = [[APMConsoleLabel alloc] initWithFrame:CGRectMake(-kDebugLabelWidth, 0, kDebugLabelWidth, kDebugLabelHeight)];
    }
    return _memoryLabel;
}

-(APMConsoleLabel *)cpuLabel {
    if (!_cpuLabel) {
        _cpuLabel = [[APMConsoleLabel alloc] initWithFrame:CGRectMake((APMScreenWidth - kDebugLabelWidth) / 2, -kDebugLabelHeight, kDebugLabelWidth, kDebugLabelHeight)];
    }
    return _cpuLabel;
}

- (APMConsoleLabel *)fpsLabel {
    if (!_fpsLabel) {
        _fpsLabel = [[APMConsoleLabel alloc] initWithFrame:CGRectMake(APMScreenWidth + kDebugLabelWidth, 0, kDebugLabelWidth, kDebugLabelHeight)];
    }
    return _fpsLabel;
}

@end
