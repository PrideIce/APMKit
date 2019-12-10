//
//  CrashModel.mm
//  DCAPM
//
//  Created by 陈逸辰 on 2019/12/6.
//  Copyright © 2019 陈逸辰. All rights reserved.
//

#import "CrashModel+WCTTableCoding.h"
#import "CrashModel.h"
#import <WCDB/WCDB.h>
#import "APMDBManger.h"

static NSString * const CrashTable = NSStringFromClass(CrashModel.class);

@implementation CrashModel

WCDB_IMPLEMENTATION(CrashModel)
WCDB_SYNTHESIZE(CrashModel, crashId)
WCDB_SYNTHESIZE(CrashModel, name)
WCDB_SYNTHESIZE(CrashModel, reason)
WCDB_SYNTHESIZE(CrashModel, timeStamp)
WCDB_SYNTHESIZE(CrashModel, timeDate)
WCDB_SYNTHESIZE(CrashModel, stack)

WCDB_PRIMARY_ASC_AUTO_INCREMENT(CrashModel, crashId)

#pragma mark - CRUD
- (BOOL)insertToDB
{
    self.isAutoIncrement = YES;
    BOOL result = [[APMDBManger getDB] insertObject:self into:CrashTable];
    return result;
}

+ (NSArray *)getAllRecords
{
    NSArray *array = [[APMDBManger getDB] getObjectsOfClass:CrashModel.class
                                                  fromTable:CrashTable
                                                    orderBy:CrashModel.timeStamp.operator*(-1).order()];
    return array;
}
  
@end
