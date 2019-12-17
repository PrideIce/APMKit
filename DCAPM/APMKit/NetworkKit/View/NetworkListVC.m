//
//  NetworkListVC.m
//  DCAPM
//
//  Created by 陈逸辰 on 2019/12/10.
//  Copyright © 2019 陈逸辰. All rights reserved.
//

#import "NetworkListVC.h"
#import "NetworkModel.h"
#import "NetworkRecordVC.h"
#import "NetworkListCell.h"

@interface NetworkListVC () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSArray *dataArray;
@property (nonatomic,strong) UISegmentedControl *segControl;
@property (nonatomic,strong) UIButton *filterBtn;
@property (nonatomic,strong) UILabel *emptyLabel;

@end

@implementation NetworkListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.title = @"网络日志";
    self.navigationItem.titleView = self.segControl;
    self.view.backgroundColor = UIColor.whiteColor;
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:self.filterBtn];
    self.navigationItem.rightBarButtonItem = buttonItem;
    
    [self.view addSubview:self.tableView];
    self.dataArray = [NetworkModel getAllRecords];
    [self reloadTableView];
}

- (void)reloadTableView
{
    if (self.dataArray.count > 0) {
        self.emptyLabel.hidden = YES;
    } else {
        self.emptyLabel.hidden = NO;
    }
    [self.tableView reloadData];
}

#pragma mark - Getter

- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc ] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.backgroundColor = UIColor.whiteColor;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = 130;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        [_tableView registerNib:[UINib nibWithNibName:@"NetworkListCell" bundle:nil] forCellReuseIdentifier:@"NetworkListCell"];
    }
    return _tableView;
}

- (UISegmentedControl *)segControl
{
    if (_segControl == nil) {
        _segControl = [[UISegmentedControl alloc] initWithItems:@[@"时间",@"大小"]];
        _segControl.selectedSegmentIndex = 0;
        [_segControl addTarget:self action:@selector(selectSegmentAction:) forControlEvents:UIControlEventValueChanged];
    }
    return _segControl;
}

- (UIButton *)filterBtn
{
    if (_filterBtn == nil) {
        _filterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _filterBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_filterBtn setImage:[UIImage imageNamed:@"filter"] forState:UIControlStateNormal];
        [_filterBtn setImage:[UIImage imageNamed:@"filter"] forState:UIControlStateHighlighted];
        [_filterBtn setTitleColor:UIColor.grayColor forState:UIControlStateNormal];
        [_filterBtn addTarget:self action:@selector(filterAciton) forControlEvents:UIControlEventTouchUpInside];
        _filterBtn.imageEdgeInsets = UIEdgeInsetsMake(5, 50, 5, -25);
        [_filterBtn sizeToFit];
    }
    return _filterBtn;
}

- (UILabel *)emptyLabel
{
    if (_emptyLabel == nil) {
        UILabel *emptyLabel = [[UILabel alloc] init];
        emptyLabel.textColor = APMFontDefaultColor;
        emptyLabel.font = [UIFont systemFontOfSize:16];
        emptyLabel.numberOfLines = 0;
        [self.view addSubview:emptyLabel];
        [emptyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.centerY.equalTo(self.view);
        }];
        emptyLabel.text = @"当前没有记录";
        _emptyLabel = emptyLabel;
    }
    return _emptyLabel;
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
    
    NetworkRecordVC *vc = [[NetworkRecordVC alloc] init];
    vc.model = [self.dataArray objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Action

- (IBAction)selectSegmentAction:(UISegmentedControl *)sender
{
    if (self.segControl.selectedSegmentIndex == 0) {
        self.dataArray = [NetworkModel getAllRecords];
    } else {
        self.dataArray = [NetworkModel getAllRecordsBySizeOrder];
    }
    [self reloadTableView];
}

- (void)filterAciton
{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil
                                                                     message:@"选择过滤条件"
                                                              preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"域名" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self popDomainTextField];
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"状态码" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self popStatusCodeTextField];
        
    }];
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertVC addAction:action1];
    [alertVC addAction:action2];
    [alertVC addAction:action3];
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)popDomainTextField
{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil
                                                                     message:@"域名过滤"
                                                              preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"请输入部分域名，例如baidu";
    }];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"查询" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        for (UITextField *textField in alertVC.textFields) {
            if (textField.text.length > 0) {
                self.dataArray = [NetworkModel getRecordsContainsDomain:textField.text];
                [self reloadTableView];
            }
        }
    }];
    [alertVC addAction:action1];
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertVC addAction:action3];
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)popStatusCodeTextField
{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil
                                                                     message:@"请选择状态码"
                                                              preferredStyle:UIAlertControllerStyleActionSheet];
   NSArray *statusCodeArray = [NetworkModel getAllStatusCode];
    for (NSNumber *statusCode in statusCodeArray) {
        if ([statusCode isKindOfClass:[NSNull class]]) {
            continue;
        }
        UIAlertAction *action = [UIAlertAction actionWithTitle:statusCode.stringValue style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.dataArray = [NetworkModel getRecordsWithStatusCode:statusCode.integerValue];
            [self reloadTableView];
        }];
        [alertVC addAction:action];
    }
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertVC addAction:action3];
    [self presentViewController:alertVC animated:YES completion:nil];
}

@end
