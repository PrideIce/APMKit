//
//  CrashKit.m
//  DCAPM
//
//  Created by 陈逸辰 on 2019/11/30.
//  Copyright © 2019 陈逸辰. All rights reserved.
//

#import "CrashKit.h"
#import "CrashListVC.h"
#import "CrashModel.h"

NSString *APMCrashRecord = @"APMCrashRecord";
static BOOL Crashed = NO;

void APM_UncaughtExceptionHandler(NSException *exception) {
    if (Crashed) return;
    Crashed = YES;
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [NSDate date];
    NSString *timeStamp = [NSString stringWithFormat:@"%lld", (long long)([date timeIntervalSince1970] * 1000)];
    NSString *timeDate = [formatter stringFromDate:date];
    NSArray *stackSymbols = [exception callStackSymbols];
    NSString *expStack = [stackSymbols componentsJoinedByString:@"\n"];
    
    CrashModel *model = [[CrashModel alloc] init];
    model.name = name;
    model.reason = reason;
    model.timeDate = timeDate;
    model.timeStamp = timeStamp;
    model.stack = expStack;
    model.screenShot = [CrashKit getScreenShot];
    [model insertToDB];
}

//Signal类型的崩溃
void APM_SignalExceptionHandler(int signal){
    
    if (Crashed) return;
    Crashed = YES;
    /*
     SIGABRT–程序中止命令中止信号
     SIGALRM–程序超时信号
     SIGFPE–程序浮点异常信号
     SIGILL–程序非法指令信号
     SIGHUP–程序终端中止信号
     SIGINT–程序键盘中断信号
     SIGKILL–程序结束接收中止信号
     SIGTERM–程序kill中止信号
     SIGSTOP–程序键盘中止信号
     SIGSEGV–程序无效内存中止信号
     SIGBUS–程序内存字节未对齐中止信号
     SIGPIPE–程序Socket发送失败中止信号
     */
    NSArray * arr = @[@"SIGHUP"
                      ,@"SIGINT"
                      ,@"SIGQUIT"
                      ,@"SIGILL"
                      ,@"SIGTRAP"
                      ,@"SIGABRT"
                      ,@"SIGPOLL"
                      ,@"SIGFPE"
                      ,@"SIGKILL"
                      ,@"SIGBUS"
                      ,@"SIGSEGV"
                      ,@"SIGSYS"
                      ,@"SIGPIPE"
                      ,@"SIGALRM"
                      ,@"SIGTERM"
                      ,@"SIGURG"
                      ,@"SIGSTOP"
                      ,@"SIGTSTP"
                      ,@"SIGCONT"
                      ,@"SIGCHLD"
                      ,@"SIGTTIN"
                      ,@"SIGTTOU"
                      ,@"SIGIO"
                      ,@"SIGXCPU"
                      ,@"SIGXFSZ"
                      ,@"SIGVTALRM"
                      ,@"SIGPROF"
                      ,@"SIGWINCH"
                      ,@"SIGINFO"
                      ,@"SIGUSR1"
                      ,@"SIGUSR2"];
    NSString * describe = @"UnKnow";
    if (signal < arr.count) {
        describe = arr[signal];
    }
    
    NSString *reason = describe;
    NSString *name = [NSString stringWithFormat:@"signal-%@",@(signal)];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [NSDate date];
    NSString *timeStamp = [NSString stringWithFormat:@"%lld", (long long)([date timeIntervalSince1970] * 1000)];
    NSString *timeDate = [formatter stringFromDate:date];
    NSArray *stackSymbols = [NSThread callStackSymbols];
    NSString *expStack = [stackSymbols componentsJoinedByString:@"\n"];
    
    CrashModel *model = [[CrashModel alloc] init];
    model.name = name;
    model.reason = reason;
    model.timeDate = timeDate;
    model.timeStamp = timeStamp;
    model.stack = expStack;
    [model insertToDB];
}

@implementation CrashKit

//+ (void)load
//{
//    [CrashKit setDefaultHandler];
//    
//    signal(SIGABRT, APM_SignalExceptionHandler);
//    signal(SIGILL, APM_SignalExceptionHandler);
//    signal(SIGSEGV, APM_SignalExceptionHandler);
//    signal(SIGFPE, APM_SignalExceptionHandler);
//    signal(SIGBUS, APM_SignalExceptionHandler);
//    signal(SIGPIPE, APM_SignalExceptionHandler);
//}

+ (void)startMonitor
{
    [CrashKit setDefaultHandler];
    
    signal(SIGABRT, APM_SignalExceptionHandler);
    signal(SIGILL, APM_SignalExceptionHandler);
    signal(SIGSEGV, APM_SignalExceptionHandler);
    signal(SIGFPE, APM_SignalExceptionHandler);
    signal(SIGBUS, APM_SignalExceptionHandler);
    signal(SIGPIPE, APM_SignalExceptionHandler);
}
   
+ (void)setDefaultHandler
{
     NSSetUncaughtExceptionHandler(&APM_UncaughtExceptionHandler);
}
   
+ (NSUncaughtExceptionHandler *)getHandler
{
     return NSGetUncaughtExceptionHandler();
}

+ (NSArray *)getAllCrashRecords
{
    return [CrashModel getAllRecords];
}
 
+ (UIImage *)getScreenShot
{
    UIView *currentView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    // 开启图片上下文
    UIGraphicsBeginImageContextWithOptions(currentView.bounds.size, NO, 0);
    // 获取当前上下文
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
    // 截图:实际是把layer上面的东西绘制到上下文中
//    [currentView.layer renderInContext:ctx];
//    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
//    [statusBar drawViewHierarchyInRect:statusBar.frame afterScreenUpdates:YES];
    //iOS7+ 推荐使用的方法，代替上述方法
    [currentView drawViewHierarchyInRect:currentView.frame afterScreenUpdates:YES];
    // 获取截图
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    // 关闭图片上下文
    UIGraphicsEndImageContext();
    
    UIImageWriteToSavedPhotosAlbum(image, NULL, NULL, NULL);
    
    return image;
}

@end
