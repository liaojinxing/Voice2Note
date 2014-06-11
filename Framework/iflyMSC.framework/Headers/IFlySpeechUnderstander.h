//
//  IFlySpeechUnderstander.
//  MSC
//
//  Created by iflytek on 2014-03-12.
//  Copyright (c) 2014年 iflytek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFlySpeechRecognizer.h"
#import "IFlySpeechError.h"

/**
语义理解接口
 */
@interface IFlySpeechUnderstander : NSObject
/** 创建语义理解对象的单例
 */
+(IFlySpeechUnderstander*) sharedInstance;

/** 开始识别
 
 同时只能进行一路会话，这次会话没有结束不能进行下一路会话，否则会报错。若有需要多次回话，请在onError回调返回后请求下一路回话。
 */
- (BOOL) startListening;

/** 停止录音
 
 调用此函数会停止录音，并开始进行语音识别
 */
- (void) stopListening;

/** 取消本次会话 */
- (void) cancel;

/** 设置识别引擎的参数
 
 识别的引擎参数(key)取值如下：
 
 1. domain：应用的领域； 取值为iat、at、search、video、poi、music、asr；iat：普通文本听写； search：热词搜索； video：视频音乐搜索； asr：关键词识别;
 2. vad_bos：前端点检测；静音超时时间，即用户多长时间不说话则当做超时处理； 单位：ms； engine指定iat识别默认值为5000； 其他情况默认值为 4000，范围 0-10000。
 3. vad_eos：后断点检测；后端点静音检测时间，即用户停止说话多长时间内即认为不再输入， 自动停止录音；单位:ms，sms 识别默认值为 1800，其他默认值为 700，范围 0-10000。
 4. sample_rate：采样率，目前支持的采样率设置有 16000 和 8000。
 5. asr_ptt：是否返回无标点符号文本； 默认为 1，当设置为 0 时，将返回无标点符号文本。
 6. asr_sch：是否需要进行语义处理，默认为0，即不进行语义识别，对于需要使用语义的应用，需要将asr_sch设为1。
 7. result_type：返回结果的数据格式，可设置为json，xml，plain，默认为json。
 8. grammarID：识别的语法 id，只针对 domain 设置为”asr”的应用。
 9. asr_audio_path：音频文件名；设置此参数后，将会自动保存识别的录音文件。路径为Documents/(指定值)。不设置或者设置为nil，则不保存音频。
 10. params：扩展参数，对于一些特殊的参数可在此设置，一般用于设置语义。
 @param key 识别引擎参数
 @param value 参数对应的取值
 
 @return 设置的参数和取值正确返回YES，失败返回NO
 */
-(BOOL) setParameter:(NSString *) value forKey:(NSString*)key;

/** 写入音频流
 
 @param audioData 音频数据
 @return 写入成功返回YES，写入失败返回NO
 */
- (BOOL) writeAudio:(NSData *) audioData;

/**
 销毁识别对象。
 */
- (BOOL) destroy;

@property (retain) IFlySpeechRecognizer * recognizer;

/**
 是否正在语义理解
 */
@property (readonly)  BOOL isUnderstanding;

/** 设置委托对象 */
@property(nonatomic,retain) id<IFlySpeechRecognizerDelegate> delegate ;

@end
