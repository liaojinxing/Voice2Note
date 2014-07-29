//
//  AppContext.h
//  Voice2Note
//
//  Created by liaojinxing on 14-6-30.
//  Copyright (c) 2014年 jinxing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppContext : NSObject

+ (instancetype)appContext;

@property (nonatomic, assign) BOOL hasUploadAddressBook;

@end
