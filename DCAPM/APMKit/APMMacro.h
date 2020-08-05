//
//  APMMacro.h
//  DCAPM
//
//  Created by 陈逸辰 on 2019/12/21.
//  Copyright © 2019 陈逸辰. All rights reserved.
//

#ifndef APMMacro_h
#define APMMacro_h

#define APMRGB(r, g, b)                         [UIColor colorWithRed:r/255.f green:g/255.f blue:b/255.f alpha:1.f]
#define APMFontDefaultColor                     APMRGB(37, 148, 255)
#define APMButtonBorderColor                    APMRGB(90, 200, 250)
#define APMBGColor                              APMRGB(243, 244, 246)

#define APMIphoneXScreen ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436) , [[UIScreen mainScreen] currentMode].size) || CGSizeEqualToSize(CGSizeMake(828, 1792) , [[UIScreen mainScreen] currentMode].size) ||CGSizeEqualToSize(CGSizeMake(750, 1624) , [[UIScreen mainScreen] currentMode].size) || CGSizeEqualToSize(CGSizeMake(1242, 2688) , [[UIScreen mainScreen] currentMode].size) : NO)

#define APMScreenWidth                         [[UIScreen mainScreen] bounds].size.width
#define APMScreenHeight                        [[UIScreen mainScreen] bounds].size.height
#define APMSafeTopHeight    (NaviBarHeight + StatusBarHeight)
#define APMSafeBottomHeight (APMIphoneXScreen ? 34 : 0)

#import <Masonry/Masonry.h>
#import "NSData+APM.h"
#import "APMUtility.h"
#import "APMBaseVC.h"

#endif /* APMMacro_h */
