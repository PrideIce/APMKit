//
//  NetworkModel.h
//  DCAPM
//
//  Created by 陈逸辰 on 2019/12/10.
//  Copyright © 2019 陈逸辰. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkModel : NSObject

@property(nonatomic, assign) NSInteger recordId;
@property (nonatomic, strong) NSURLRequest *request;
//@property (nonatomic, copy) NSString *request;
@property (nonatomic, copy) NSString *response;
@property (nonatomic, copy) NSString *requestTime;
@property (nonatomic, copy) NSString *responseTime;
@property (nonatomic, copy) NSString *data;
@property (nonatomic, copy) NSString *error;

#pragma mark - CRUD
- (BOOL)insertToDB;

+ (NSArray *)getAllRecords;

@end
