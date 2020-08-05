//
//  NetworkTrafficVC.m
//  APM
//
//  Created by 陈逸辰 on 2020/7/2.
//

#import "NetworkTrafficVC.h"
#import "NetworkModel.h"
#import "NetworkTrafficListVC.h"

@interface NetworkTrafficVC () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UILabel *overViewLabel;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSArray *dataArray;

@end

@implementation NetworkTrafficVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
       
    [self initUI];
    
    [self initData];
}

- (void)initData
{
    self.dataArray = [NetworkModel getSortedTrafficByURLHost];
    [self.tableView reloadData];
    
    NSNumber *sum = [NetworkModel getTrafficSum];
    NSNumber *up = [NetworkModel getUploadTrafficSum];
    NSNumber *down = [NetworkModel getDownloadTrafficSum];
    self.overViewLabel.text = [NSString stringWithFormat:@"总体流量：%@\n上行流量：%@\n下行流量：%@",
                               [APMUtility getFileSizeOfLength:sum.longLongValue],
                               [APMUtility getFileSizeOfLength:up.longLongValue],
                               [APMUtility getFileSizeOfLength:down.longLongValue]];
}

- (void)initUI
{
    self.view.backgroundColor = UIColor.whiteColor;
    self.navigationController.navigationBar.translucent = NO;
    
    [self.view addSubview:self.overViewLabel];
    [self.overViewLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(15);
        make.top.equalTo(self.view).offset(10);
        make.height.mas_equalTo(80);
    }];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.top.mas_equalTo(100);
    }];
}

#pragma mark - Getter

- (UILabel *)overViewLabel
{
    if (!_overViewLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.textColor = UIColor.darkGrayColor;
        label.font = [UIFont boldSystemFontOfSize:16];
        label.numberOfLines = 0;
        _overViewLabel = label;
    }
    return _overViewLabel;
}

- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.backgroundColor = UIColor.whiteColor;
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
    static NSString *cellIdentifier = @"ListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSDictionary *dict = [self.dataArray objectAtIndex:indexPath.row];
    NSString *host = dict[@"host"];
    cell.textLabel.text = host;
    NSNumber *trafficSize = dict[@"traffic"];
    NSString *sizeString = [APMUtility getFileSizeOfLength:trafficSize.longLongValue];
    cell.detailTextLabel.text = sizeString;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section == 0 ? 30 : 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, APMScreenWidth, 30)];
    view.backgroundColor = APMRGB(243, 244, 246);
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, 300, 25)];
    label.text = @"流量排行榜";
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = APMFontDefaultColor;
    [view addSubview:label];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return section == 0 ? 0.1 : 74;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dict = [self.dataArray objectAtIndex:indexPath.row];
    NetworkTrafficListVC *vc = [NetworkTrafficListVC new];
    vc.host = dict[@"host"];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
