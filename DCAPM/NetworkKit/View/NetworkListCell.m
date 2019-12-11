//
//  NetworkListCell.m
//  DCAPM
//
//  Created by 陈逸辰 on 2019/12/11.
//  Copyright © 2019 陈逸辰. All rights reserved.
//

#import "NetworkListCell.h"

@interface NetworkListCell ()

@property (weak, nonatomic) IBOutlet UILabel *urlLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *downSizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *uploadSizeLabel;

@end

@implementation NetworkListCell

- (void)awakeFromNib {
    [super awakeFromNib];

}

- (void)setModel:(NetworkModel *)model
{
    _model = model;
    self.urlLabel.text = model.request.URL.absoluteString;
}

@end
