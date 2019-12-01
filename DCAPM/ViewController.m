//
//  ViewController.m
//  DCAPM
//
//  Created by 陈逸辰 on 2019/11/30.
//  Copyright © 2019 陈逸辰. All rights reserved.
//

#import "ViewController.h"
#import "CrashListVC.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)crashAction:(id)sender
{
    CrashListVC *vc = [[CrashListVC alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}


@end
