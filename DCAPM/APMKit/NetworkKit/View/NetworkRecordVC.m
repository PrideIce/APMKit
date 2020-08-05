//
//  NetworkRecordVC.m
//  DCAPM
//
//  Created by 陈逸辰 on 2019/12/12.
//  Copyright © 2019 陈逸辰. All rights reserved.
//

#import "NetworkRecordVC.h"
#import "NetworkRecordTableView.h"
#import "APMMacro.h"

@interface NetworkRecordVC ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet NetworkRecordTableView *tableView;

@property (nonatomic,strong) NSArray<NSString*> *requestSetions;
@property (nonatomic,strong) NSDictionary *requestRowsDict;
@property (nonatomic,strong) NSArray<NSString*> *responseSetions;
@property (nonatomic,strong) NSDictionary *responseRowsDict;
@property (nonatomic,strong) NSArray<NSString*> *timeSections;
@property (nonatomic,strong) NSDictionary *timeRowsDict;


@end

@implementation NetworkRecordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = APMRGB(243, 244, 246);
    self.title = @"网络详情";
    
    [self initDataInfo];
    [self selectSegmentAction:self.segmentControl];
}

- (void)initDataInfo
{
    //请求
    self.requestSetions = @[@"消息体",@"链接",@"请求头",@"请求行"];
    NSMutableArray *arr1 = [NSMutableArray array];
    NSString *requestLength = [APMUtility getFileSizeOfLength:_model.requestDataLength];
    [arr1 addObject:[NetworkRecordEntry entryWithLeftInfo:@"数据大小" rightInfo:requestLength showEntrance:NO]];
    [arr1 addObject:[NetworkRecordEntry entryWithLeftInfo:_model.response.MIMEType]];
    
    NSMutableArray *arr2 = [NSMutableArray array];
    [arr2 addObject:[NetworkRecordEntry entryWithLeftInfo:_model.request.URL.absoluteString]];
    
    NSMutableArray *arr3 = [NSMutableArray array];
    NSDictionary *headers = _model.request.allHTTPHeaderFields;
    NSMutableString *requestHeader = [NSMutableString string];
    for (NSString *key in headers.allKeys) {
        [requestHeader appendFormat:@"%@ : %@\n", key, headers[key]];
    }
    if (requestHeader.length > 2) {
        [requestHeader deleteCharactersInRange:NSMakeRange(requestHeader.length - 2, 2)];
    }
    [arr3 addObject:[NetworkRecordEntry entryWithLeftInfo:requestHeader]];
    
    NSMutableArray *arr4 = [NSMutableArray array];
    NSString *lineStr = [NSString stringWithFormat:@"%@ %@ %@", _model.request.HTTPMethod, _model.request.URL.path, @"HTTP/1.1"];
    [arr4 addObject:[NetworkRecordEntry entryWithLeftInfo:lineStr]];
    self.requestRowsDict = @{@"消息体":arr1,
                             @"链接":arr2,
                             @"请求头":arr3,
                             @"请求行":arr4};
    //响应
    self.responseSetions = @[@"状态码",@"响应头",@"响应内容"];
    NSMutableArray *response1 = [NSMutableArray array];
    [response1 addObject:[NetworkRecordEntry entryWithLeftInfo:[NSString stringWithFormat:@"%ld",(long)_model.response.statusCode]]];
    
    NSMutableArray *response2 = [NSMutableArray array];
    headers = _model.response.allHeaderFields;
    NSMutableString *responseHeader = [NSMutableString string];
    for (NSString *key in headers.allKeys) {
        [responseHeader appendFormat:@"%@ : %@\n", key, headers[key]];
    }
    if (responseHeader.length > 2) {
        [responseHeader deleteCharactersInRange:NSMakeRange(responseHeader.length - 2, 2)];
    }
    [response2 addObject:[NetworkRecordEntry entryWithLeftInfo:responseHeader]];
    
    NSMutableArray *response3 = [NSMutableArray array];
    [response3 addObject:[NetworkRecordEntry entryWithLeftInfo:_model.data.jsonString]];
    self.responseRowsDict = @{@"状态码":response1,
                              @"响应头":response2,
                              @"响应内容":response3};
    //概览
    //时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    self.timeSections = @[@"开始时间",@"结束时间",@"总共耗时"];
    NSMutableArray *startTime = [NSMutableArray array];
    NSDate *sDate = [NSDate dateWithTimeIntervalSince1970:_model.startTime];
    [startTime addObject:[NetworkRecordEntry entryWithLeftInfo:[formatter stringFromDate:sDate]]];
    
    NSMutableArray *endTime = [NSMutableArray array];
    NSDate *eDate = [NSDate dateWithTimeIntervalSince1970:_model.endTime];
    [endTime addObject:[NetworkRecordEntry entryWithLeftInfo:[formatter stringFromDate:eDate]]];
    
    NSMutableArray *lengthOfTime = [NSMutableArray array];
    NSTimeInterval timeOffset = _model.endTime - _model.startTime;
    [lengthOfTime addObject:[NetworkRecordEntry entryWithLeftInfo:[NSString stringWithFormat:@"%.03fs",timeOffset]]];
    self.timeRowsDict = @{@"开始时间":startTime,
                          @"结束时间":endTime,
                          @"总共耗时":lengthOfTime};
    
}

- (IBAction)selectSegmentAction:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == 0) {
        self.tableView.setions = self.requestSetions;
        self.tableView.rowsDict = self.requestRowsDict;
    } else if (sender.selectedSegmentIndex == 1) {
        self.tableView.setions = self.responseSetions;
        self.tableView.rowsDict = self.responseRowsDict;
    } else if (sender.selectedSegmentIndex == 2) {
        self.tableView.setions = @[];
        self.tableView.rowsDict = @{};
    } else if (sender.selectedSegmentIndex == 3) {
        self.tableView.setions = self.timeSections;
        self.tableView.rowsDict = self.timeRowsDict;
    }
    [self.tableView reloadData];
}

@end
