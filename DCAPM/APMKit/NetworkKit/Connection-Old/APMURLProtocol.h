//
//  APMURLProtocol.h
//  DCAPM
//
//  Created by 陈逸辰 on 2019/12/10.
//  Copyright © 2019 陈逸辰. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface APMURLProtocol : NSURLProtocol

+ (void)startMonitor;

+ (void)endMonitor;

@end

NS_ASSUME_NONNULL_END
