//
//  NetworkTrafficListVC.m
//  APM
//
//  Created by 陈逸辰 on 2020/7/2.
//

#import "NetworkTrafficListVC.h"
#import "NetworkModel.h"
#import "NetworkRecordVC.h"
#import "NetworkListCell.h"
#import "APMMacro.h"

@interface NetworkTrafficListVC () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSArray *dataArray;

@end

@implementation NetworkTrafficListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = self.host;
    
    [self.view addSubview:self.tableView];
    self.dataArray = [NetworkModel getRecordsWithHost:_host];
}

#pragma mark - Getter

- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc ] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.backgroundColor = UIColor.whiteColor;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = 130;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        [_tableView registerNib:[UINib nibWithNibName:@"NetworkListCell" bundle:bundle] forCellReuseIdentifier:@"NetworkListCell"];
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
    
    NetworkRecordVC *vc = [NetworkRecordVC instanceFromXib];
    vc.model = [self.dataArray objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
