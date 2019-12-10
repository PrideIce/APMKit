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

@interface APMMonitorVC ()

@property (nonatomic) BOOL isAnimating;
@property (nonatomic,strong) UIButton *crashBtn;
@property (nonatomic,strong) UIButton *networkBtn;
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
    
    self.title = @"监控系统";
    self.view.backgroundColor = UIColor.whiteColor;
    
    [self.view addSubview:self.crashBtn];
    [self.crashBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(60));
        make.height.equalTo(@(30));
        make.center.equalTo(self.view);
    }];
    
    [self.view addSubview:self.networkBtn];
    [self.networkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(60));
        make.height.equalTo(@(30));
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.crashBtn.mas_bottom).offset(30);
    }];
    
    CGFloat bottomHeight = -30 - APMSafeBottomHeight;
    [self.view addSubview:self.exitBtn];
    [self.exitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(60));
        make.height.equalTo(@(30));
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
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        [button setTitle:@"Crash" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(crashAction:) forControlEvents:UIControlEventTouchUpInside];
        button.layer.borderWidth = 1;
        button.layer.cornerRadius = 5;
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
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        [button setTitle:@"Network" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(networkAction:) forControlEvents:UIControlEventTouchUpInside];
        button.layer.borderWidth = 1;
        button.layer.cornerRadius = 5;
        button.layer.borderColor = APMFontDefaultColor.CGColor;
        _networkBtn = button;
    }
    return _networkBtn;
}

- (UIButton *)exitBtn
{
    if (!_exitBtn) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitleColor:APMFontDefaultColor forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        [button setTitle:@"Exit" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(exitAction:) forControlEvents:UIControlEventTouchUpInside];
        button.layer.borderWidth = 1;
        button.layer.cornerRadius = 5;
        button.layer.borderColor = APMFontDefaultColor.CGColor;
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

- (void)exitAction:(id)sender
{
    [APMMonitorVC hide];
}


@end
