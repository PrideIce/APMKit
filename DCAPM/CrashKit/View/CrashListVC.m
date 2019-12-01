//
//  CrashListVC.m
//  DCAPM
//
//  Created by 陈逸辰 on 2019/11/30.
//  Copyright © 2019 陈逸辰. All rights reserved.
//

#import "CrashListVC.h"
#import "CrashKit.h"

extern NSString *APMCrashRecord;

@interface CrashListVC () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSArray *dataArray;

@end

@implementation CrashListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"崩溃报告";
    
    self.dataArray = @[];
    [self.view addSubview:self.tableView];
    [self initData];
}

- (void)initData
{
//    NSString *resultStr = [NSString stringWithContentsOfFile:[CrashKit getLogFilePath] encoding:NSUTF8StringEncoding error:nil];
    //NSLog(@"resultStr is %@", resultStr);
//    NSArray *crashArray = [resultStr componentsSeparatedByString:@"=============Crash Report============="];
    
    NSArray *crashArray = [[NSUserDefaults standardUserDefaults] objectForKey:APMCrashRecord];
    self.dataArray = crashArray;
    [self.tableView reloadData];
}

#pragma mark - Getter

- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CrashListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *dict = [self.dataArray objectAtIndex:indexPath.row];
    cell.textLabel.text = dict[@"time"] ?: @"无法显示";
    return cell;
}

#pragma mark - UITableViewDelegate


@end
