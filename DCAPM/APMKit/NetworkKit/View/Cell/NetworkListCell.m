//
//  NetworkListCell.m
//  DCAPM
//
//  Created by 陈逸辰 on 2019/12/11.
//  Copyright © 2019 陈逸辰. All rights reserved.
//

#import "NetworkListCell.h"
#import "APMMacro.h"

@interface NetworkListCell ()

@property (weak, nonatomic) IBOutlet UILabel *urlLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;

@end

@implementation NetworkListCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.typeLabel.layer.masksToBounds = YES;
    self.typeLabel.layer.cornerRadius = 4;
}

- (void)setModel:(NetworkModel *)model
{
    _model = model;
    self.urlLabel.text = model.request.URL.absoluteString;
    
    self.typeLabel.text = [NSString stringWithFormat:@" %@ > %@ ", model.request.HTTPMethod, model.response.MIMEType];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:model.startTime];
    self.timeLabel.text = [NSString stringWithFormat:@"[%ld] %@", (long)model.response.statusCode,[formatter stringFromDate:date]];
    self.sizeLabel.text = [NSString stringWithFormat:@"↓ %@  ↑ %@", [APMUtility getFileSizeOfLength:model.data.length], [APMUtility getFileSizeOfLength:model.requestDataLength]];
}

@end
