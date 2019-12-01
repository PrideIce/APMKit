//
//  CrashDetailVC.m
//  DCAPM
//
//  Created by 陈逸辰 on 2019/12/1.
//  Copyright © 2019 陈逸辰. All rights reserved.
//

#import "CrashDetailVC.h"
#import <Masonry/Masonry.h>

@interface CrashDetailVC ()

@property (nonatomic,strong) UILabel *stackLabel;

@end

@implementation CrashDetailVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"崩溃信息";
    
    self.stackLabel = [[UILabel alloc] init];
    self.stackLabel.textColor = UIColor.blackColor;
    self.stackLabel.backgroundColor = UIColor.whiteColor;
    self.stackLabel.font = [UIFont systemFontOfSize:20];
    self.stackLabel.numberOfLines = 0;
    [self.view addSubview:self.stackLabel];
    [self.stackLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.view);
    }];
    
    self.stackLabel.text = [self.data objectForKey:@"stack"];
}

@end
