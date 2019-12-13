//
//  NetworkRecordTableView.m
//  DCAPM
//
//  Created by 陈逸辰 on 2019/12/12.
//  Copyright © 2019 陈逸辰. All rights reserved.
//

#import "NetworkRecordTableView.h"

@implementation NetworkRecordEntry

+ (instancetype)entryWithLeftInfo:(NSString *)leftInfo rightInfo:(NSString *)rightInfo showEntrance:(BOOL)showEntrance
{
    NetworkRecordEntry *entry = [[NetworkRecordEntry alloc] init];
    entry.leftInfo = leftInfo;
    entry.rightInfo = rightInfo;
    entry.showEntrance = showEntrance;
    return entry;
}

+ (instancetype)entryWithLeftInfo:(NSString *)leftInfo
{
    return [NetworkRecordEntry entryWithLeftInfo:leftInfo rightInfo:@"" showEntrance:NO];
}

@end



@interface NetworkRecordTableView () <UITableViewDataSource,UITableViewDelegate>

@end

@implementation NetworkRecordTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.dataSource = self;
        self.delegate = self;
        self.estimatedRowHeight = 100;
        self.rowHeight = UITableViewAutomaticDimension;
        self.backgroundColor = APMRGB(243, 244, 246);
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.dataSource = self;
        self.delegate = self;
        self.estimatedRowHeight = 100;
        self.rowHeight = UITableViewAutomaticDimension;
        self.backgroundColor = APMRGB(243, 244, 246);
    }
    return self;
}

#pragma mark — UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.setions.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *sectionTitle = [self.setions objectAtIndex:section];
    NSArray *rows = [_rowsDict objectForKey:sectionTitle];
    return rows ? rows.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.textLabel.numberOfLines = 0;
    }
    
    NSString *sectionTitle = [self.setions objectAtIndex:indexPath.section];
    NSArray *rows = [_rowsDict objectForKey:sectionTitle];
    NetworkRecordEntry *entry = [rows objectAtIndex:indexPath.row];
    
    cell.textLabel.text = entry.leftInfo;
    cell.detailTextLabel.text = entry.rightInfo;
    cell.accessoryType = entry.showEntrance ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, APMScreenWidth, 30)];
    view.backgroundColor = APMRGB(243, 244, 246);
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, 300, 25)];
    label.text = [self.setions objectAtIndex:section];
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor grayColor];
    [view addSubview:label];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

@end
