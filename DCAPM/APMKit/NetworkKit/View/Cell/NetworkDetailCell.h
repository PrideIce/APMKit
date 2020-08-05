//
//  NetworkDetailCell.h
//  DCAPM
//
//  Created by 陈逸辰 on 2019/12/18.
//  Copyright © 2019 陈逸辰. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NetworkDetailCell : UITableViewCell

//@property (weak, nonatomic) IBOutlet UILabel *leftLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UITextView *leftTextView;
@property (weak, nonatomic) IBOutlet UILabel *rightLabel;

@end

NS_ASSUME_NONNULL_END
