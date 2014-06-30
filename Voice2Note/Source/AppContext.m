//
//  AppContext.m
//  Voice2Note
//
//  Created by liaojinxing on 14-6-30.
//  Copyright (c) 2014年 jinxing. All rights reserved.
//

#import "AppContext.h"

static NSString* kHasUploadImageKey = @"kHasUploadImageKey";

@implementation AppContext

+ (instancetype)appContext
{
  static id instance = nil;
  static dispatch_once_t onceToken = 0L;
  dispatch_once(&onceToken, ^{
    instance = [[AppContext alloc] init];
  });
  return instance;
}

- (BOOL)hasUploadImage
{
  return [[[NSUserDefaults standardUserDefaults] objectForKey:kHasUploadImageKey] boolValue];
}

- (void)setHasUploadImage:(BOOL)hasUploadImage
{
  [[NSUserDefaults standardUserDefaults] setBool:hasUploadImage forKey:kHasUploadImageKey];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
