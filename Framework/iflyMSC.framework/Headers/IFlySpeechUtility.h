//
//  IFlySpeechUtility.h
//  MSCDemo
//
//  Created by admin on 14-5-7.
//  Copyright (c) 2014年 iflytek. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IFlySpeechError.h"

/** 用户配置
 */
@class IFlySpeechUtility;

@interface IFlySpeechUtility : NSObject
{
    
}

/** 创建用户语音配置。
 
 注册应用请前往语音云开发者网站。<br>
 网站：http://open.voicecloud.cn/developer.php
 @param params 启动参数，必须保证appid参数传入，示例：appid=123456
 @return 语音配置
 */
+ (IFlySpeechUtility*) createUtility:(NSString *) params;

/** 销毁用户配置对象
 */
+(BOOL) destroy;


/** 获取用户配置对象
 */
+(IFlySpeechUtility *) getUtility;

/** 是否登陆
 
 @return  登陆返回YES，未登录返回NO
 */
//+ (BOOL) isLogin;

//+ (IFlySpeechError *) login;

//+(void) logout;


@end
