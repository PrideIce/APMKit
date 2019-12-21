//
//  APMMonitorVC.m
//  DCAPM
//
//  Created by 陈逸辰 on 2019/12/3.
//  Copyright © 2019 陈逸辰. All rights reserved.
//

#import "APMMonitorVC.h"
#import "APMKit.h"
#import "UIView+APM.h"
#import "CrashListVC.h"
#import "NetworkListVC.h"
#import "PerformanceKit.h"
#import "APMMacro.h"

@interface APMMonitorVC ()

@property (nonatomic) BOOL isAnimating;
@property (nonatomic,strong) UIButton *crashBtn;
@property (nonatomic,strong) UIButton *networkBtn;
@property (nonatomic,strong) UIButton *trafficBtn;
@property (nonatomic,strong) UIButton *hardworkBtn;
@property (nonatomic,strong) UIButton *memoryBtn;
@property (nonatomic,strong) UIButton *catonBtn;
@property (nonatomic,strong) UIButton *exitBtn;

@end

@implementation APMMonitorVC

+ (instancetype)shared
{
    static APMMonitorVC *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[APMMonitorVC alloc] init];
    });
    return instance;
}

+ (UINavigationController *)navVc
{
    static UINavigationController *navVc;
    static dispatch_once_t sencondToken;
    dispatch_once(&sencondToken, ^{
        navVc = [[UINavigationController alloc] initWithRootViewController:APMMonitorVC.shared];
        CGRect frame = UIScreen.mainScreen.applicationFrame;
        frame.origin.y = -frame.size.height;
        navVc.view.frame = frame;
    });
    return navVc;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"移动端监控系统";
    self.view.backgroundColor = UIColor.whiteColor;
    
    CGFloat btnWidth = 85;
    CGFloat btnHeigth = 35;
    CGFloat offsetX = 70;
    [self.view addSubview:self.crashBtn];
    [self.crashBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(btnWidth));
        make.height.equalTo(@(btnHeigth));
        make.top.equalTo(self.view).offset(110);
        make.centerX.equalTo(self.view).offset(-offsetX);
    }];
    
    [self.view addSubview:self.networkBtn];
    [self.networkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(btnWidth));
        make.height.equalTo(@(btnHeigth));
        make.top.equalTo(self.crashBtn);
        make.centerX.equalTo(self.view).offset(offsetX);
    }];
    
    [self.view addSubview:self.trafficBtn];
    [self.trafficBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(btnWidth));
        make.height.equalTo(@(btnHeigth));
       make.top.equalTo(self.crashBtn.mas_bottom).offset(40);
        make.centerX.equalTo(self.view).offset(-offsetX);
    }];
    
    [self.view addSubview:self.hardworkBtn];
    [self.hardworkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(btnWidth));
        make.height.equalTo(@(btnHeigth));
        make.top.equalTo(self.trafficBtn);
        make.centerX.equalTo(self.view).offset(offsetX);
    }];
    
    [self.view addSubview:self.memoryBtn];
    [self.memoryBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(btnWidth));
        make.height.equalTo(@(btnHeigth));
        make.top.equalTo(self.hardworkBtn.mas_bottom).offset(40);
        make.centerX.equalTo(self.view).offset(-offsetX);
    }];
    
    [self.view addSubview:self.catonBtn];
    [self.catonBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(btnWidth));
        make.height.equalTo(@(btnHeigth));
        make.top.equalTo(self.memoryBtn);
        make.centerX.equalTo(self.view).offset(offsetX);
    }];
    
    CGFloat bottomHeight = -50 - APMSafeBottomHeight;
    [self.view addSubview:self.exitBtn];
    [self.exitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(btnWidth));
        make.height.equalTo(@(btnHeigth));
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(bottomHeight);
    }];
}

+ (void)show
{
    if (APMMonitorVC.navVc.view.superview == nil && !APMMonitorVC.shared.isAnimating) {
        APMMonitorVC.shared.isAnimating = YES;
        UIWindow *mainWindow = [UIApplication sharedApplication].keyWindow;
        [mainWindow findAndResignFirstResponder];
        [mainWindow addSubview:APMMonitorVC.navVc.view];
        
        [UIView animateWithDuration:0.5 animations:^{
            APMMonitorVC.navVc.view.frame = UIScreen.mainScreen.applicationFrame;
        } completion:^(BOOL finished) {
            [[UIApplication sharedApplication].keyWindow findAndResignFirstResponder];
            APMMonitorVC.shared.isAnimating = NO;
        }];
    }
}

+ (void)hide
{
    if (APMMonitorVC.navVc.view.superview != nil && !APMMonitorVC.shared.isAnimating) {
        APMMonitorVC.shared.isAnimating = YES;
        UIWindow *mainWindow = [UIApplication sharedApplication].keyWindow;
        [mainWindow findAndResignFirstResponder];
        CGRect frame = UIScreen.mainScreen.applicationFrame;
        frame.origin.y = -frame.size.height;
        
        [UIView animateWithDuration:0.5 animations:^{
            APMMonitorVC.navVc.view.frame = frame;
        } completion:^(BOOL finished) {
            [APMMonitorVC.navVc.view removeFromSuperview];
            APMMonitorVC.shared.isAnimating = NO;
        }];
    }
}

#pragma mark - Getter

- (UIButton *)crashBtn
{
    if (!_crashBtn) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitleColor:APMFontDefaultColor forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:16];
        [button setTitle:@"崩溃记录" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(crashAction:) forControlEvents:UIControlEventTouchUpInside];
        button.layer.borderWidth = 1.5;
        button.layer.cornerRadius = 10;
        button.layer.borderColor = APMFontDefaultColor.CGColor;
        _crashBtn = button;
    }
    return _crashBtn;
}

- (UIButton *)networkBtn
{
    if (!_networkBtn) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitleColor:APMFontDefaultColor forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:16];
        [button setTitle:@"网络监控" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(networkAction:) forControlEvents:UIControlEventTouchUpInside];
        button.layer.borderWidth = 1.5;
        button.layer.cornerRadius = 10;
        button.layer.borderColor = APMFontDefaultColor.CGColor;
        _networkBtn = button;
    }
    return _networkBtn;
}

- (UIButton *)trafficBtn
{
    if (!_trafficBtn) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitleColor:UIColor.grayColor forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:16];
        [button setTitle:@"流量统计" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(unsupportAction:) forControlEvents:UIControlEventTouchUpInside];
        button.layer.borderWidth = 1.5;
        button.layer.cornerRadius = 8;
        button.layer.borderColor = UIColor.grayColor.CGColor;
        _trafficBtn = button;
    }
    return _trafficBtn;
}

- (UIButton *)hardworkBtn
{
    if (!_hardworkBtn) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitleColor:APMFontDefaultColor forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:16];
        [button setTitle:@"性能监控" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(performainceAciton:) forControlEvents:UIControlEventTouchUpInside];
        button.layer.borderWidth = 1.5;
        button.layer.cornerRadius = 8;
        button.layer.borderColor = APMFontDefaultColor.CGColor;
        _hardworkBtn = button;
    }
    return _hardworkBtn;
}

- (UIButton *)memoryBtn
{
    if (!_memoryBtn) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitleColor:UIColor.grayColor forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:16];
        [button setTitle:@"内存泄露" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(unsupportAction:) forControlEvents:UIControlEventTouchUpInside];
        button.layer.borderWidth = 1.5;
        button.layer.cornerRadius = 8;
        button.layer.borderColor = UIColor.grayColor.CGColor;
        _memoryBtn = button;
    }
    return _memoryBtn;
}

- (UIButton *)catonBtn
{
    if (!_catonBtn) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitleColor:UIColor.grayColor forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:16];
        [button setTitle:@"卡顿记录" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(unsupportAction:) forControlEvents:UIControlEventTouchUpInside];
        button.layer.borderWidth = 1.5;
        button.layer.cornerRadius = 8;
        button.layer.borderColor = UIColor.grayColor.CGColor;
        _catonBtn = button;
    }
    return _catonBtn;
}

- (UIButton *)exitBtn
{
    if (!_exitBtn) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitleColor:UIColor.systemPinkColor forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:16];
        [button setTitle:@"退 出" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(exitAction:) forControlEvents:UIControlEventTouchUpInside];
        button.layer.borderWidth = 1.5;
        button.layer.cornerRadius = 5;
        button.layer.borderColor = UIColor.systemPinkColor.CGColor;
        _exitBtn = button;
    }
    return _exitBtn;
}

#pragma mark - Action

- (void)crashAction:(id)sender
{
    CrashListVC *vc = [[CrashListVC alloc] init];
    [APMMonitorVC.shared.navigationController pushViewController:vc animated:YES];
}

- (void)networkAction:(id)sender
{
    NetworkListVC *vc = [[NetworkListVC alloc] init];
    [APMMonitorVC.shared.navigationController pushViewController:vc animated:YES];
}

- (void)performainceAciton:(id)sender
{
    [PerformanceKit toggleWith:APMTypeAll];
}

- (void)exitAction:(id)sender
{
    [APMMonitorVC hide];
}

- (void)unsupportAction:(id)sender
{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"该功能即将在2.0版本开放，敬请关注。" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
    [alertVC addAction:sureAction];
    UIAlertAction *sureAction2 = [UIAlertAction actionWithTitle:@"提建议" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertVC addAction:sureAction2];
    [self presentViewController:alertVC animated:YES completion:nil];
}

@end
