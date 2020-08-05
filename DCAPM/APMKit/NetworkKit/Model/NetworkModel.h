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
@property (nonatomic, copy) NSString *host;
@property (nonatomic, assign) NSInteger statusCode;
@property (nonatomic, assign) NSTimeInterval startTime;
@property (nonatomic, assign) NSTimeInterval endTime;
@property (nonatomic, assign) NSTimeInterval totalDuration;
@property (nonatomic, strong) NSData *data;
@property (nonatomic, copy) NSString *error;
@property (nonatomic, assign) NSInteger requestDataLength;
@property (nonatomic, assign) NSInteger responseDataLength;
@property (nonatomic, assign) NSInteger totalDataLength;

#pragma mark - CRUD
- (BOOL)insertToDB;

+ (NSArray *)getAllRecords;

+ (NSArray *)getRecordsWithCount:(NSUInteger)count;

+ (NSArray *)getRecordsBySizeOrderWithCount:(NSUInteger)count;

+ (NSArray *)getRecordsByTimeDurationWithCount:(NSUInteger)count;

+ (NSArray *)getAllStatusCode;

+ (NSArray *)getRecordsWithStatusCode:(NSInteger)statusCode;

+ (NSArray *)getRecordsContainsDomain:(NSString *)domain;

+ (NSDictionary *)getTrafficGroupByURLHost;

+ (NSArray *)getSortedTrafficByURLHost;

+ (NSNumber *)getTrafficSum;

+ (NSNumber *)getUploadTrafficSum;

+ (NSNumber *)getDownloadTrafficSum;

+ (NSArray *)getRecordsWithHost:(NSString *)host;

@end
