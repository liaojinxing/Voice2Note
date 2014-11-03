//
//  UIColor+VNHex.h
//  Voice2Note
//
//  Created by liaojinxing on 14-6-12.
//  Copyright (c) 2014年 jinxing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (VNHex)

+ (UIColor *) colorWithHex:(NSInteger)rgbHexValue;

+ (UIColor *) colorWithHex:(NSInteger)rgbHexValue alpha:(CGFloat)alpha;

+ (UIColor *)systemColor;

+ (UIColor *)systemDarkColor;

+ (UIColor *)grayBackgroudColor;

@end
