//
//  HomeController.m
//  Voice2Note
//
//  Created by liaojinxing on 14-6-11.
//  Copyright (c) 2014年 jinxing. All rights reserved.
//

#import "HomeController.h"
#import "NoteListController.h"
#import "VNConstants.h"
#import "iflyMSC/IFlyRecognizerView.h"
#import "iflyMSC/IFlySpeechConstant.h"
#import "iflyMSC/IFlySpeechUtility.h"
#import "iflyMSC/IFlyRecognizerView.h"

static const CGFloat kButtonHeight = 100;
static const CGFloat kHorizontalMargin = 10;
static const CGFloat kVerticalMargin = 10;


@interface HomeController ()<IFlyRecognizerViewDelegate>
{
  UITextView *_textView;
  UIButton *_recognizeButton;
  IFlyRecognizerView *_iflyRecognizerView;
}

@end

@implementation HomeController

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self setupNavigationBar];
  [self initComps];
  [self setupSpeechRecognizer];
}

- (void)setupNavigationBar
{
  self.navigationItem.title = kAppName;
  UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"更多"
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(moreActionButtonPressed)];
  self.navigationItem.rightBarButtonItem = rightItem;

  UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"过往"
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(gotoListView)];
  self.navigationItem.leftBarButtonItem = leftItem;
}

- (void)initComps
{
  _recognizeButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [_recognizeButton setFrame:CGRectMake((self.view.frame.size.width - kButtonHeight) / 2,
                                        self.view.frame.size.height - kButtonHeight - kVerticalMargin * 2,
                                        kButtonHeight,
                                        kButtonHeight)];
  [_recognizeButton setBackgroundColor:[UIColor redColor]];
  _recognizeButton.layer.cornerRadius = kButtonHeight / 2;
  _recognizeButton.layer.masksToBounds = YES;
  [_recognizeButton addTarget:self action:@selector(startListenning) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:_recognizeButton];

  CGFloat y = 70;
  _textView = [[UITextView alloc] initWithFrame:CGRectMake(kHorizontalMargin, y,
                                                           self.view.frame.size.width - kHorizontalMargin * 2,
                                                           _recognizeButton.frame.origin.y - y - kVerticalMargin * 2)];
  [_textView setEditable:YES];
  [_textView setScrollEnabled:NO];
  [self.view addSubview:_textView];

  UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                              _recognizeButton.frame.origin.y - kVerticalMargin,
                                                              self.view.frame.size.width,
                                                              1.0f)];
  [lineView setBackgroundColor:[UIColor orangeColor]];
  [self.view addSubview:lineView];

  UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panToHideKeyboard:)];
  [self.view addGestureRecognizer:gestureRecognizer];
}

- (void)setupSpeechRecognizer
{
  NSString *initString = [NSString stringWithFormat:@"%@=%@", [IFlySpeechConstant APPID], kIFlyAppID];

  [IFlySpeechUtility createUtility:initString];
  _iflyRecognizerView = [[IFlyRecognizerView alloc] initWithCenter:self.view.center];
  _iflyRecognizerView.delegate = self;

  [_iflyRecognizerView setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
  [_iflyRecognizerView setParameter:@"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
  // | result_type   | 返回结果的数据格式，可设置为json，xml，plain，默认为json。
  [_iflyRecognizerView setParameter:@"plain" forKey:[IFlySpeechConstant RESULT_TYPE]];
}

- (void)viewWillDisappear:(BOOL)animated
{
  [IFlySpeechUtility destroy];
}

/**
   启动按钮响应方法
 */
- (void)startListenning
{
  [_iflyRecognizerView start];
  NSLog(@"start listenning...");
}

#pragma mark IFlyRecognizerViewDelegate
/** 识别结果回调方法
   @param resultArray 结果列表
   @param isLast YES 表示最后一个，NO表示后面还有结果
 */
- (void)onResult:(NSArray *)resultArray isLast:(BOOL)isLast
{
  NSMutableString *result = [[NSMutableString alloc] init];
  NSDictionary *dic = [resultArray objectAtIndex:0];
  for (NSString *key in dic) {
    [result appendFormat:@"%@", key];
  }
  _textView.text = [NSString stringWithFormat:@"%@%@", _textView.text, result];
}

/** 识别结束回调方法
   @param error 识别错误
 */
- (void)onError:(IFlySpeechError *)error
{
  NSLog(@"errorCode:%d", [error errorCode]);
}

#pragma mark - Keyboard
- (void)panToHideKeyboard:(UIPanGestureRecognizer *)recognizer
{
  if ((recognizer.state == UIGestureRecognizerStateChanged) ||
      (recognizer.state == UIGestureRecognizerStateEnded)) {
    CGPoint velocity = [recognizer velocityInView:self.view];

    if (velocity.y > 0) { // panning down
      if ([_textView isFirstResponder]) {
        [_textView resignFirstResponder];
      }
    }
  }
}

#pragma mark - Action

- (void)moreActionButtonPressed
{
}

- (void)gotoListView
{
  if ([_textView isFirstResponder]) {
    [_textView resignFirstResponder];
  }
  NoteListController *listController = [[NoteListController alloc] init];
  [self.navigationController pushViewController:listController animated:YES];
}

@end
