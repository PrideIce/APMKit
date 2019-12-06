//
//  CrashModel.h
//  DCAPM
//
//  Created by 陈逸辰 on 2019/12/6.
//  Copyright © 2019 陈逸辰. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CrashModel : NSObject

@property(nonatomic, assign) NSInteger crashId;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *reason;
@property(nonatomic, copy) NSString *timeStamp;
@property(nonatomic, copy) NSString *timeDate;
@property(nonatomic, copy) NSString *stack;

#pragma mark - 增
- (BOOL)insertToDB;

+ (NSArray *)getAllRecords;

@end
