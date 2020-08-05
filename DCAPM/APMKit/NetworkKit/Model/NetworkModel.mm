//
//  NetworkModel.mm
//  DCAPM
//
//  Created by 陈逸辰 on 2019/12/10.
//  Copyright © 2019 陈逸辰. All rights reserved.
//

#import "NetworkModel+WCTTableCoding.h"
#import "NetworkModel.h"
#import <WCDB/WCDB.h>
#import "APMDBManger.h"

static NSString * const NetworkTable = NSStringFromClass(NetworkModel.class);

@implementation NetworkModel

WCDB_IMPLEMENTATION(NetworkModel)
WCDB_SYNTHESIZE(NetworkModel, recordId)
WCDB_SYNTHESIZE(NetworkModel, request)
WCDB_SYNTHESIZE(NetworkModel, response)
WCDB_SYNTHESIZE(NetworkModel, url)
WCDB_SYNTHESIZE(NetworkModel, host)
WCDB_SYNTHESIZE(NetworkModel, statusCode)
WCDB_SYNTHESIZE(NetworkModel, startTime)
WCDB_SYNTHESIZE(NetworkModel, endTime)
WCDB_SYNTHESIZE(NetworkModel, totalDuration)
WCDB_SYNTHESIZE(NetworkModel, data)
WCDB_SYNTHESIZE(NetworkModel, error)
WCDB_SYNTHESIZE(NetworkModel, requestDataLength)
WCDB_SYNTHESIZE(NetworkModel, responseDataLength)
WCDB_SYNTHESIZE(NetworkModel, totalDataLength)

WCDB_PRIMARY_ASC_AUTO_INCREMENT(NetworkModel, recordId)

#pragma mark - CRUD
- (BOOL)insertToDB
{
    self.isAutoIncrement = YES;
    BOOL result = [[APMDBManger defaultDB] insertObject:self into:NetworkTable];
    return result;
}

+ (NSArray *)getAllRecords
{
    NSArray *array = [[APMDBManger defaultDB] getObjectsOfClass:NetworkModel.class
                                                      fromTable:NetworkTable
                                                        orderBy:NetworkModel.recordId.order(WCTOrderedDescending)];
    return array;
}

+ (NSArray *)getRecordsWithCount:(NSUInteger)count
{
    NSArray *array = [[APMDBManger defaultDB] getObjectsOfClass:NetworkModel.class
                                                      fromTable:NetworkTable
                                                        orderBy:NetworkModel.recordId.order(WCTOrderedDescending)
                                                          limit:count];
    return array;
}

+ (NSArray *)getRecordsBySizeOrderWithCount:(NSUInteger)count
{
    NSArray *array = [[APMDBManger defaultDB] getObjectsOfClass:NetworkModel.class
                                                      fromTable:NetworkTable
                                                        orderBy:NetworkModel.totalDataLength.order(WCTOrderedDescending)
                                                          limit:count];
    return array;
}

+ (NSArray *)getRecordsByTimeDurationWithCount:(NSUInteger)count
{
    NSArray *array = [[APMDBManger defaultDB] getObjectsOfClass:NetworkModel.class
                                                      fromTable:NetworkTable
                                                        orderBy:NetworkModel.totalDuration.order(WCTOrderedDescending)
                                                          limit:count];
    return array;
}

+ (NSArray *)getAllStatusCode
{
    NSArray *array = [[APMDBManger defaultDB] getOneDistinctColumnOnResult:NetworkModel.statusCode fromTable:NetworkTable];
    return array;
}

+ (NSArray *)getRecordsWithStatusCode:(NSInteger)statusCode
{
    NSArray *array = [[APMDBManger defaultDB] getObjectsOfClass:NetworkModel.class
                                                      fromTable:NetworkTable
                                                        where:NetworkModel.statusCode == statusCode];
    return array;
}

+ (NSArray *)getRecordsContainsDomain:(NSString *)domain
{
    NSString *likeQuery = [@"%" stringByAppendingString:domain];
    likeQuery = [likeQuery stringByAppendingString:@"%"];
    NSArray *array = [[APMDBManger defaultDB] getObjectsOfClass:NetworkModel.class
                                                      fromTable:NetworkTable
                                                          where:NetworkModel.url.like(likeQuery)];
    return array;
}

+ (NSDictionary *)getTrafficGroupByURLHost
{
    NSMutableDictionary *trafficDict = @{}.mutableCopy;
    NSArray *hostArray = [[APMDBManger defaultDB] getOneDistinctColumnOnResult:NetworkModel.host fromTable:NetworkTable];
    for (NSString *host in hostArray) {
        if ([host isKindOfClass:NSNull.class]) continue;
        NSNumber *trafficOfHost = [[APMDBManger defaultDB] getOneValueOnResult:NetworkModel.totalDataLength.sum() fromTable:NetworkTable where:NetworkModel.host == host];
        [trafficDict setObject:trafficOfHost forKey:host];
    }
    return trafficDict;
}

+ (NSArray *)getSortedTrafficByURLHost
{
    NSMutableArray *trafficArray = @[].mutableCopy;
    NSArray *hostArray = [[APMDBManger defaultDB] getOneDistinctColumnOnResult:NetworkModel.host fromTable:NetworkTable];
    for (NSString *host in hostArray) {
        if ([host isKindOfClass:NSNull.class]) continue;
        NSNumber *trafficOfHost = [[APMDBManger defaultDB] getOneValueOnResult:NetworkModel.totalDataLength.sum() fromTable:NetworkTable where:NetworkModel.host == host];
        [trafficArray addObject:@{@"traffic":trafficOfHost,
                                  @"host":host
        }];
    }
    [trafficArray sortUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        NSNumber *num1 = obj1[@"traffic"];
        NSNumber *num2 = obj2[@"traffic"];
        if (num1.longLongValue > num2.longLongValue) {
            return NSOrderedAscending;
        } else {
            return NSOrderedDescending;
        }
    }];
    return trafficArray;
}

+ (NSNumber *)getTrafficSum
{
    NSNumber *traffic = [[APMDBManger defaultDB] getOneValueOnResult:NetworkModel.totalDataLength.sum() fromTable:NetworkTable];
    return traffic;
}

+ (NSNumber *)getUploadTrafficSum
{
    NSNumber *traffic = [[APMDBManger defaultDB] getOneValueOnResult:NetworkModel.requestDataLength.sum() fromTable:NetworkTable];
    return traffic;
}

+ (NSNumber *)getDownloadTrafficSum
{
    NSNumber *traffic = [[APMDBManger defaultDB] getOneValueOnResult:NetworkModel.responseDataLength.sum() fromTable:NetworkTable];
    return traffic;
}

+ (NSArray *)getRecordsWithHost:(NSString *)host
{
    NSArray *array = [[APMDBManger defaultDB] getObjectsOfClass:NetworkModel.class fromTable:NetworkTable where:NetworkModel.host == host orderBy:NetworkModel.totalDataLength.order(WCTOrderedDescending)];
    return array;
}

@end
