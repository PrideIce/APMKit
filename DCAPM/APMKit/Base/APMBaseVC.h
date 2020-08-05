//
//  APMBaseVC.h
//  APM
//
//  Created by 陈逸辰 on 2020/3/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface APMBaseVC : UIViewController

+ (instancetype)instanceFromXib;

+ (instancetype)instanceFromStoryBoard;

@end

NS_ASSUME_NONNULL_END
