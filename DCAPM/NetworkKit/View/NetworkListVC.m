//
//  NetworkListVC.m
//  DCAPM
//
//  Created by 陈逸辰 on 2019/12/10.
//  Copyright © 2019 陈逸辰. All rights reserved.
//

#import "NetworkListVC.h"
#import "NetworkModel.h"
#import "NetworkDetailVC.h"
#import "NetworkListCell.h"

@interface NetworkListVC () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSArray *dataArray;

@end

@implementation NetworkListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"网络日志";
    self.view.backgroundColor = UIColor.whiteColor;
    
    [self initData];
}

- (void)initData
{
    NSArray *crashArray = [NetworkModel getAllRecords];
    self.dataArray = crashArray ?: @[];
    if (self.dataArray.count > 0) {
        [self.view addSubview:self.tableView];
        [self.tableView reloadData];
    } else {
        UILabel *emptyLabel = [[UILabel alloc] init];
        emptyLabel.textColor = APMFontDefaultColor;
        emptyLabel.font = [UIFont systemFontOfSize:18];
        emptyLabel.numberOfLines = 0;
        [self.view addSubview:emptyLabel];
        [emptyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.centerY.equalTo(self.view);
        }];
        emptyLabel.text = @"当前没有记录";
    }
}

#pragma mark - Getter

- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.backgroundColor = UIColor.whiteColor;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = 130;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        [_tableView registerNib:[UINib nibWithNibName:@"NetworkListCell" bundle:nil] forCellReuseIdentifier:@"NetworkListCell"];
    }
    return _tableView;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"NetworkListCell";
    NetworkListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    NetworkModel *model = [self.dataArray objectAtIndex:indexPath.row];
    cell.model = model;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section == 0 ? 0.1 : 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return section == 0 ? 0.1 : 74;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NetworkDetailVC *vc = [[NetworkDetailVC alloc] init];
    vc.model = [self.dataArray objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

@end