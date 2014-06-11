//
//  IFlySpeechConstant.h
//  MSCDemo
//
//  Created by iflytek on 5/9/14.
//  Copyright (c) 2014 iflytek. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 公共常量，主要定义参数的key值
 */
@interface IFlySpeechConstant : NSObject

/**识别录音保存路径
 */
+(NSString*) ASR_AUDIO_PATH;

/**语言区域。
 */
+(NSString*)ACCENT;

/**语音应用ID
 
 通过开发者网站申请
 */
+(NSString*)APPID;

/**设置是否有标点符号
 */
+(NSString*)ASR_PTT;

/**
语言
 
支持：zh_cn，zh_tw，en_us<br>
 */
+(NSString*)LANGUAGE;

/**
 返回结果的数据格式，可设置为json，xml，plain，默认为json。
 */
+(NSString*) RESULT_TYPE;

/**云端语法ID
 */
+(NSString*)CLOUD_GRAMMAR;

/**应用领域。
 */
+(NSString*)IFLY_DOMAIN;

/**个性化数据上传类型
 */
+(NSString*)DATA_TYPE;

/** 语音输入超时时间
 
 单位：ms，默认30000
 */
+(NSString*) SPEECH_TIMEOUT;

/** 网络连接超时时间
 
 单位：ms，默认20000
 */
+(NSString*)NET_TIMEOUT;

/**开放语义协议版本号。
 
 如需使用请在http://osp.voicecloud.cn/上进行业务配置
 */
+(NSString*)NLP_VERSION;

/** 扩展参数。
 */
+(NSString*)PARAMS;

/**合成及识别采样率。
 */
+(NSString*)SAMPLE_RATE;

/** 语速（0~100）
 
 默认值:50
 */
+(NSString*)SPEED;

/**
音调（0~100）
 
默认值:50
 */
+(NSString*)PITCH;

/** 合成录音保存路径
 */
+(NSString*)TTS_AUDIO_PATH;

/** VAD前端点超时<br>
 
 可选范围：0-10000(单位ms)<br>
 */
+(NSString*)VAD_BOS;

/** 
VAD后端点超时 。<br>
 
可选范围：0-10000(单位ms)<br>
 */
+(NSString*)VAD_EOS;

/** 发音人。

  云端支持发音人：小燕（xiaoyan）、小宇（xiaoyu）、凯瑟琳（Catherine）、
  亨利（henry）、玛丽（vimary）、小研（vixy）、小琪（vixq）、
  小峰（vixf）、小梅（vixm）、小莉（vixl）、小蓉（四川话）、
  小芸（vixyun）、小坤（vixk）、小强（vixqa）、小莹（vixying）、 小新（vixx）、楠楠（vinn）老孙（vils）<br>
  对于网络TTS的发音人角色，不同引擎类型支持的发音人不同，使用中请注意选择。
 */
+(NSString*)VOICE_NAME;

/**音量（0~100） 默认值:50
 */
+(NSString*)VOLUME ;


@end
