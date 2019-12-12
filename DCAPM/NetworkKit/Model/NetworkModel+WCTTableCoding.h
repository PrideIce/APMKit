//
//  NetworkModel+WCTTableCoding.h
//  DCAPM
//
//  Created by 陈逸辰 on 2019/12/10.
//  Copyright © 2019 陈逸辰. All rights reserved.
//

#import "NetworkModel.h"
#import <WCDB/WCDB.h>

@interface NetworkModel (WCTTableCoding) <WCTTableCoding>

WCDB_PROPERTY(recordId)
WCDB_PROPERTY(request)
WCDB_PROPERTY(response)
WCDB_PROPERTY(startTime)
WCDB_PROPERTY(responseTime)
WCDB_PROPERTY(totalDuration)
WCDB_PROPERTY(data)
WCDB_PROPERTY(error)

@end
