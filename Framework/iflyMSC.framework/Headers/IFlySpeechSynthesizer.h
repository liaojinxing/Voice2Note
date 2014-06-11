//
//  IFlySpeechSynthesizer.h
//  MSC
//
//  Created by ypzhao on 13-3-21.
//  Copyright (c) 2013年 iflytek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFlySpeechSynthesizerDelegate.h"

/** 语音合成  */

@interface IFlySpeechSynthesizer : NSObject<IFlySpeechSynthesizerDelegate>

/** 设置识别的委托对象 */
@property(nonatomic,assign) id<IFlySpeechSynthesizerDelegate> delegate;

/** 返回合成对象的单例
 */
+ (id) sharedInstance;

/**
 销毁识别对象。
 */
+ (BOOL) destroy;

/** 设置合成参数
 
 设置参数需要在调用startSpeaking:之前进行。
 
 参数的名称和取值：
 
 1. speed：合成语速,取值范围 0~100
 2. volume：合成的音量,取值范围 0~100
 3. voice_name：默认为”xiaoyan”；可以设置的参数列表可参考个性化发音人列表
 4. sample_rate：目前支持的采样率有 16000 和 8000
 5. tts_audio_path：音频文件名 设置此参数后，将会自动保存合成的音频文件。路径为Documents/(指定值)。不设置或者设置为nil，则不保存音频。
 6. params：扩展参数
 
 @param key  合成参数
 @param value 参数取值
 @return 设置成功返回YES，失败返回NO
 */
-(BOOL) setParameter:(NSString *) value forKey:(NSString*)key;

/** 获取合成参数
 
 @param key 参数名称
 */
//-(NSString*) getParameter:(NSString *)key;


/** 开始合成
 
 调用此函数进行合成，如果发生错误会回调错误`onCompleted`
 
 @param text 合成的文本,最大的字节数为1k
 */
- (void) startSpeaking:(NSString *)text;

/** 暂停播放
 
 暂停播放之后，合成不会暂停，仍会继续，如果发生错误则会回调错误`onCompleted`
 */
- (void) pauseSpeaking;

/** 恢复播放 */
- (void) resumeSpeaking;


/** 停止播放并停止合成
 */
- (void) stopSpeaking;

/** 是否正在播放
 */
@property (nonatomic, readonly) BOOL isSpeaking;

@end
