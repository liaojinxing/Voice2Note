//
//  NSDate+Conversion.m
//  Voice2Note
//
//  Created by liaojinxing on 14/11/3.
//  Copyright (c) 2014年 jinxing. All rights reserved.
//

#import "NSDate+Conversion.h"

@implementation NSDate(Conversion)

+ (BOOL)isSameDay:(NSDate *)firstDate andDate:(NSDate *)secondDate
{
  return [NSDate daysBetweenDate:firstDate andDate:secondDate] == 0 ? YES : NO;
}

+ (NSInteger)daysBetweenDate:(NSDate *)firstDate andDate:(NSDate *)secondDate
{
  if (firstDate == nil || secondDate == nil) {
    return NSIntegerMax;
  }
  NSCalendar *currentCalendar = [NSCalendar currentCalendar];
  NSDateComponents *components = [currentCalendar components:NSCalendarUnitDay
                                                    fromDate:firstDate
                                                      toDate:secondDate
                                                     options:0];
  NSInteger days = [components day];
  return days;
}

@end
