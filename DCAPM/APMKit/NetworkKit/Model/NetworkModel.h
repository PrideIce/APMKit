//
//  NetworkModel.h
//  DCAPM
//
//  Created by 陈逸辰 on 2019/12/10.
//  Copyright © 2019 陈逸辰. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkModel : NSObject

@property (nonatomic, assign) NSInteger recordId;
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSHTTPURLResponse *response;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, assign) NSInteger statusCode;
@property (nonatomic, assign) NSTimeInterval startTime;
@property (nonatomic, copy) NSString *responseTime;
@property (nonatomic, copy) NSString *totalDuration;
@property (nonatomic, strong) NSData *data;
@property (nonatomic, copy) NSString *error;
@property (nonatomic, assign) NSInteger requestDataLength;
@property (nonatomic, assign) NSInteger totalDataLength;

#pragma mark - CRUD
- (BOOL)insertToDB;

+ (NSArray *)getAllRecords;

+ (NSArray *)getAllRecordsBySizeOrder;

+ (NSArray *)getAllStatusCode;

+ (NSArray *)getRecordsWithStatusCode:(NSInteger)statusCode;

+ (NSArray *)getRecordsContainsDomain:(NSString *)domain;

@end