//
//  AppDelegate.m
//  DCAPM
//
//  Created by 陈逸辰 on 2019/11/30.
//  Copyright © 2019 陈逸辰. All rights reserved.
//

#import "AppDelegate.h"
#import "APMKit.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [APMKit startAPM];
    
    NSArray *array = [NSArray arrayWithObject:@"there is only one objective in this arary,call index one, app will crash and throw an exception!"];
//    NSLog(@"%@", [array objectAtIndex:1]);
    
    NSString *browseUrl = [NSString stringWithFormat:@"https://www.sojson.com/open/api/weather/json.shtml?city=%@", @"北京"];
    NSString *gitHubUrl = @"https://api.github.com/search/users?q=language:objective-c&sort=followers&order=desc";
    NSURLSession *session = [NSURLSession sharedSession];
       NSURLSessionDataTask *task = [session dataTaskWithURL:[NSURL URLWithString:gitHubUrl] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
           NSLog(@"请求完成");
       }];
       [task resume];
    
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
