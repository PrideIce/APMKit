//
//  NetworkListCell.h
//  DCAPM
//
//  Created by 陈逸辰 on 2019/12/11.
//  Copyright © 2019 陈逸辰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NetworkListCell : UITableViewCell

@property (nonatomic,strong) NetworkModel *model;

@end

NS_ASSUME_NONNULL_END
