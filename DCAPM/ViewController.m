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

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"APM Demo";
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


- (IBAction)requestAction:(id)sender {
    [self postRequest];
}

- (void)getRequest
{
    NSString *browseUrl = [NSString stringWithFormat:@"https://www.sojson.com/open/api/weather/json.shtml?city=%@", @"北京"];
    NSString *gitHubUrl = @"https://api.github.com/search/users?q=language:objective-c&sort=followers&order=desc";
    NSURLSession *session = [NSURLSession sharedSession];
       NSURLSessionDataTask *task = [session dataTaskWithURL:[NSURL URLWithString:gitHubUrl] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
           NSLog(@"请求完成");
       }];
       [task resume];
}

-(void)postRequest
{
    //对请求路径的说明
    //http://120.25.226.186:32812/login
    //协议头+主机地址+接口名称
    //协议头(http://)+主机地址(120.25.226.186:32812)+接口名称(login)
    //POST请求需要修改请求方法为POST，并把参数转换为二进制数据设置为请求体
    
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
    
    //6.根据会话对象创建一个Task(发送请求）
    /*
     第一个参数：请求对象
     第二个参数：completionHandler回调（请求完成【成功|失败】的回调）
                data：响应体信息（期望的数据）
                response：响应头信息，主要是对服务器端的描述
                error：错误信息，如果请求失败，则error有值
     */
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        //8.解析数据
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        NSLog(@"%@",dict);
        
    }];
    
    //7.执行任务
    [dataTask resume];
}


@end
