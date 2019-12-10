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
WCDB_SYNTHESIZE(NetworkModel, requestTime)
WCDB_SYNTHESIZE(NetworkModel, responseTime)
WCDB_SYNTHESIZE(NetworkModel, data)
WCDB_SYNTHESIZE(NetworkModel, error)

WCDB_PRIMARY_ASC_AUTO_INCREMENT(NetworkModel, recordId)

#pragma mark - CRUD
- (BOOL)insertToDB
{
    self.isAutoIncrement = YES;
    BOOL result = [[APMDBManger getDB] insertObject:self into:NetworkTable];
    return result;
}

+ (NSArray *)getAllRecords
{
    NSArray *array = [[APMDBManger getDB] getObjectsOfClass:NetworkModel.class
                                                  fromTable:NetworkTable
                                                    orderBy:NetworkModel.recordId.operator*(-1).order()];
    return array;
}

@end
