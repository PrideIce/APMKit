//
//  CrashModel+WCTTableCoding.h
//  DCAPM
//
//  Created by 陈逸辰 on 2019/12/6.
//  Copyright © 2019 陈逸辰. All rights reserved.
//

#import "CrashModel.h"
#import <WCDB/WCDB.h>

@interface CrashModel (WCTTableCoding) <WCTTableCoding>

WCDB_PROPERTY(crashId)
WCDB_PROPERTY(name)
WCDB_PROPERTY(reason)
WCDB_PROPERTY(timeStamp)
WCDB_PROPERTY(timeDate)
WCDB_PROPERTY(stack)

@end
