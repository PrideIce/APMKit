//
//  APMDBManger.h
//  DCAPM
//
//  Created by 陈逸辰 on 2019/12/6.
//  Copyright © 2019 陈逸辰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WCDB/WCDB.h>

NS_ASSUME_NONNULL_BEGIN

@interface APMDBManger : NSObject

+ (WCTDatabase *)getDB;

@end

NS_ASSUME_NONNULL_END
