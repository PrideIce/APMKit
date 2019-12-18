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
WCDB_SYNTHESIZE(NetworkModel, statusCode)
WCDB_SYNTHESIZE(NetworkModel, startTime)
WCDB_SYNTHESIZE(NetworkModel, responseTime)
WCDB_SYNTHESIZE(NetworkModel, totalDuration)
WCDB_SYNTHESIZE(NetworkModel, data)
WCDB_SYNTHESIZE(NetworkModel, error)
WCDB_SYNTHESIZE(NetworkModel, requestDataLength)
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

+ (NSArray *)getAllRecordsBySizeOrder
{
    NSArray *array = [[APMDBManger defaultDB] getObjectsOfClass:NetworkModel.class
                                                      fromTable:NetworkTable
                                                        orderBy:NetworkModel.totalDataLength.order(WCTOrderedDescending)];
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

@end
