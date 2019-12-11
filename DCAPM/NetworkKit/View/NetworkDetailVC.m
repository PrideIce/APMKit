//
//  NetworkDetailVC.m
//  DCAPM
//
//  Created by 陈逸辰 on 2019/12/10.
//  Copyright © 2019 陈逸辰. All rights reserved.
//

#import "NetworkDetailVC.h"

@interface NetworkDetailVC ()

@property (nonatomic,strong) UITextView *textview;

@end

@implementation NetworkDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"网络详情";
    
    NSString *reason = self.model.request.description ?: @"";
    NSString *name =  self.model.data ?: @"";
    NSString *time = self.model.requestTime ?: @"";
    NSString *expStack = self.model.response ?: @"";
    NSString *crashInfo = [NSString stringWithFormat:@"=============Crash Report=============\nTime: %@\nName: %@\nReason: %@\nCallStackSymbols:\n%@\n\n\n",time,name,reason,expStack];
    self.textview.text = reason;
    [self.view addSubview:self.textview];
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)];
    [self.textview addGestureRecognizer:pinchGesture];
}

#pragma mark - Getter

- (UITextView *)textview
{
    if (_textview == nil) {
        _textview = [[UITextView alloc] initWithFrame:self.view.bounds];
        _textview.editable = NO;
        _textview.font = [UIFont systemFontOfSize:13];
    }
    return _textview;
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
