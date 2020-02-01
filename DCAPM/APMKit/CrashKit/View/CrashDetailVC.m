//
//  CrashDetailVC.m
//  DCAPM
//
//  Created by 陈逸辰 on 2019/12/1.
//  Copyright © 2019 陈逸辰. All rights reserved.
//

#import "CrashDetailVC.h"
#import "APMMacro.h"

@interface CrashDetailVC ()

@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UILabel *stackLabel;
@property (nonatomic,strong) UITextView *textview;
@property (nonatomic,strong) UILabel *tipLabel;
@property (nonatomic,strong) UIImageView *screenShotImageView;

@end

@implementation CrashDetailVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"崩溃日志";
    
    NSString *reason = self.model.reason ?: @"";
    NSString *name = self.model.name ?: @"";
    NSString *time = self.model.timeDate ?: @"";
    NSString *expStack = self.model.stack ?: @"";
    NSString *crashInfo = [NSString stringWithFormat:@"=============Crash Report=============\nTime: %@\nName: %@\nReason: %@\n\nCallStackSymbols:\n%@\n\n\n",time,name,reason,expStack];
    self.textview.text = crashInfo;
//    [self.view addSubview:self.textview];
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)];
    [self.textview addGestureRecognizer:pinchGesture];
    
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.textview];
    [self.scrollView addSubview:self.tipLabel];
    [self.scrollView addSubview:self.screenShotImageView];
}

#pragma mark - Getter

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        // 2.初始化、配置scrollView
        _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        _scrollView.backgroundColor = [UIColor whiteColor];
        _scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.textview.frame.size.height + 30 + self.screenShotImageView.frame.size.height - APMSafeBottomHeight);
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.bounces = NO;
        _scrollView.bouncesZoom = NO;
    }
    return _scrollView;
}

- (UITextView *)textview
{
    if (_textview == nil) {
        _textview = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 200)];
        _textview.editable = NO;
        _textview.font = [UIFont systemFontOfSize:13];
    }
    return _textview;
}

- (UIImageView *)screenShotImageView
{
    if (!_screenShotImageView) {
        _screenShotImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.textview.bounds.size.height + 30, self.view.bounds.size.width, self.view.bounds.size.height)];
        _screenShotImageView.image = _model.screenShot;
    }
    
    return _screenShotImageView;
}

- (UILabel *)tipLabel
{
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, self.textview.frame.size.height, 200, 30)];
        _tipLabel.text = @"闪退截屏：";
    }
    return _tipLabel;
}

#pragma mark - TextView

- (void)pinchGesture:(UIPinchGestureRecognizer *)gestureRecognizer
{
    NSLog(@"*** Pinch: Scale: %f Velocity: %f", gestureRecognizer.scale, gestureRecognizer.velocity);

    UIFont *font = self.textview.font;
    CGFloat pointSize = font.pointSize;
    NSString *fontName = font.fontName;

    pointSize = ((gestureRecognizer.velocity > 0) ? 1 : -1) * 0.5 + pointSize;
    
    if (pointSize < 13) pointSize = 13;
    if (pointSize > 36) pointSize = 36;
    
    self.textview.font = [UIFont fontWithName:fontName size:pointSize];
}

@end
