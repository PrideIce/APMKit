//
//  CrashModel.h
//  DCAPM
//
//  Created by 陈逸辰 on 2019/12/6.
//  Copyright © 2019 陈逸辰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CrashModel : NSObject

@property(nonatomic, assign) NSInteger crashId;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *reason;
@property(nonatomic, copy) NSString *timeStamp;
@property(nonatomic, copy) NSString *timeDate;
@property(nonatomic, copy) NSString *stack;
@property(nonatomic, strong) UIImage *screenShot;

#pragma mark - CRUD
- (BOOL)insertToDB;

+ (NSArray *)getAllRecords;

@end
