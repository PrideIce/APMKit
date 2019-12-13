//
//  NetworkRecordTableView.h
//  DCAPM
//
//  Created by 陈逸辰 on 2019/12/12.
//  Copyright © 2019 陈逸辰. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NetworkRecordEntry : NSObject

@property (nonatomic,copy) NSString *leftInfo;
@property (nonatomic,copy) NSString *rightInfo;
@property (nonatomic) BOOL showEntrance;

+ (instancetype)entryWithLeftInfo:(NSString *)leftInfo rightInfo:(NSString *)rightInfo showEntrance:(BOOL)showEntrance;

+ (instancetype)entryWithLeftInfo:(NSString *)leftInfo;

@end

@interface NetworkRecordTableView : UITableView

@property (nonatomic,strong) NSArray<NSString*> *setions;
@property (nonatomic,strong) NSDictionary *rowsDict;

@end

NS_ASSUME_NONNULL_END
