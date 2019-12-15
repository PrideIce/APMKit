//
//  APMUtility.m
//  DCAPM
//
//  Created by 陈逸辰 on 2019/12/15.
//  Copyright © 2019 陈逸辰. All rights reserved.
//

#import "APMUtility.h"

@implementation APMUtility

+ (NSString *)getFileSizeOfLength:(long long)length
{
    long kb = 1024;
    long mb = kb * 1024;
    long gb = mb * 1024;
    
    if (length >= gb) {
        return [NSString stringWithFormat:@"%.2fGB", (float)length / gb];
    } else if (length >= mb) {
        float f = (float)length / mb;
        if (f > 100) {
            return [NSString stringWithFormat:@"%.0fMB", f];
        } else {
            return [NSString stringWithFormat:@"%.2fMB", f];
        }
    } else if (length >= kb) {
        float f = (float)length / kb;
        if (f > 100) {
            return [NSString stringWithFormat:@"%.0fKB", f];
        } else {
            return [NSString stringWithFormat:@"%.2fKB", f];
        }
    } else return [NSString stringWithFormat:@"%lldB", length];
}


@end
