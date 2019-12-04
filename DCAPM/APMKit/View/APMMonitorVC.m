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

@interface APMMonitorVC ()

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"监控系统";
    self.view.backgroundColor = UIColor.blueColor;
}

+ (void)show
{
    if (APMMonitorVC.shared.view.superview == nil) {
        UIWindow *mainWindow = [UIApplication sharedApplication].keyWindow;
        [mainWindow findAndResignFirstResponder];
        [mainWindow addSubview:APMMonitorVC.shared.view];
        
        [UIView animateWithDuration:0.4 animations:^{
            APMMonitorVC.shared.view.frame = UIScreen.mainScreen.applicationFrame;
        } completion:^(BOOL finished) {
            [[UIApplication sharedApplication].keyWindow findAndResignFirstResponder];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [APMMonitorVC.shared crashAction:nil];
            });
        }];
    }
}

+ (void)hide
{
    if (APMMonitorVC.shared.view.superview != nil) {
        UIWindow *mainWindow = [UIApplication sharedApplication].keyWindow;
        [mainWindow findAndResignFirstResponder];
        CGRect frame = UIScreen.mainScreen.applicationFrame;
        frame.origin.y = -frame.size.height;
        
        [UIView animateWithDuration:0.4 animations:^{
            APMMonitorVC.shared.view.frame = frame;
        } completion:^(BOOL finished) {
            [APMMonitorVC.shared.view removeFromSuperview];
        }];
    }
}

- (void)crashAction:(id)sender
{
    CrashListVC *vc = [[CrashListVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
