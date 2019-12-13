//
//  APMDBManger.m
//  DCAPM
//
//  Created by 陈逸辰 on 2019/12/6.
//  Copyright © 2019 陈逸辰. All rights reserved.
//

#import "APMDBManger.h"
#import "CrashModel.h"
#import "NetworkModel.h"

static NSString * const AMPDataBase = @"Documents/DataBase/AMPDB.db";

@interface APMDBManger ()

@property (nonatomic,strong) WCTDatabase *wcdb;

@end

@implementation APMDBManger

#pragma mark - DB && Table

+ (instancetype)shared
{
    static APMDBManger *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[APMDBManger alloc] init];
    });
    return instance;
}

+ (WCTDatabase *)defaultDB
{
    if (!APMDBManger.shared.wcdb) {
        NSString *DBName = AMPDataBase;
        NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:DBName];
        APMDBManger.shared.wcdb = [[WCTDatabase alloc] initWithPath:path];
        [self createTable];
    }
    return APMDBManger.shared.wcdb;
}

+ (BOOL)openDB
{
    return [[self defaultDB] canOpen];
}

+ (void)closeDB
{
    [APMDBManger.shared.wcdb close];
}

+ (void)createTable
{
    NSString *crashTable = NSStringFromClass(CrashModel.class);
    NSString *networkTable = NSStringFromClass(NetworkModel.class);
    if ([APMDBManger.shared.wcdb canOpen]) {
        [APMDBManger.shared.wcdb createTableAndIndexesOfName:crashTable withClass:CrashModel.class];
        [APMDBManger.shared.wcdb createTableAndIndexesOfName:networkTable withClass:NetworkModel.class];
    }
}

@end
