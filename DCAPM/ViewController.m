//
//  ViewController.m
//  DCAPM
//
//  Created by 陈逸辰 on 2019/11/30.
//  Copyright © 2019 陈逸辰. All rights reserved.
//

#import "ViewController.h"
#import "CrashListVC.h"
#import "APMMonitorVC.h"
#import "PerformanceKit.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"APM Demo";
    self.tipLabel.text = @"Tip: 任何界面三指下滑可调出APM监控面板，\n三指上滑关闭画面。";
}

- (IBAction)monitorAction:(id)sender
{
    [APMMonitorVC show];
}


- (IBAction)crashAction:(id)sender
{
    CrashListVC *vc = [[CrashListVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


- (IBAction)requestAction:(id)sender
{
    [self getRequest];
    //    [self postRequest];
}

- (void)getRequest
{
    NSString *gitHubUrl = @"https://api.github.com/search/users?q=language:objective-c&sort=followers&order=desc";
    NSURLSession *session = [NSURLSession sharedSession];
       NSURLSessionDataTask *task = [session dataTaskWithURL:[NSURL URLWithString:gitHubUrl] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
           NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
           NSLog(@"返回数据：%@",dict);
           NSLog(@"请求完成");
       }];
       [task resume];
}

-(void)postRequest
{
    //1.创建会话对象
    NSURLSession *session = [NSURLSession sharedSession];
    
    //2.根据会话对象创建task
    NSURL *url = [NSURL URLWithString:@"https://api.github.com/search/users"];
    
    //3.创建可变的请求对象
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    //4.修改请求方法为POST
    request.HTTPMethod = @"POST";
    
    //5.设置请求体
    request.HTTPBody = [@"q=language:objective-c&sort=followers&order=desc" dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        //8.解析数据
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        NSLog(@"%@",dict);
        
    }];
    
    //7.执行任务
    [dataTask resume];
}


@end
