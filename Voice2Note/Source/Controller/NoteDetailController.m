//
//  NoteDetailController.m
//  Voice2Note
//
//  Created by liaojinxing on 14-6-11.
//  Copyright (c) 2014年 jinxing. All rights reserved.
//

#import "NoteDetailController.h"
#import "SVProgressHUD.h"
#import "VNConstants.h"
#import "iflyMSC/IFlyRecognizerView.h"
#import "iflyMSC/IFlySpeechConstant.h"
#import "iflyMSC/IFlySpeechUtility.h"
#import "iflyMSC/IFlyRecognizerView.h"
@import MessageUI;


static const CGFloat kViewOriginY = 70;
static const CGFloat kTextFieldHeight = 30;
static const CGFloat kToolbarHeight = 44;

static const CGFloat kVoiceButtonWidth = 160;
static const CGFloat kButtonHeight = 44;


@interface NoteDetailController () <IFlyRecognizerViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate>
{
  VNNote *_note;
  UITextField *_titleTextField;
  UITextView *_contentTextView;
  
  UIButton *_emailButton;
  UIButton *_weixinButton;
  UIButton *_voiceButton;
  
  IFlyRecognizerView *_iflyRecognizerView;
}
@end


@implementation NoteDetailController

- (instancetype)initWithNote:(VNNote *)note
{
  self = [super init];
  if (self) {
    _note = note;
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  [self initComps];
  [self setupNavigationBar];
  [self setupSpeechRecognizer];
  
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillShow:)
                                               name:UIKeyboardWillShowNotification
                                             object:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillHide:)
                                               name:UIKeyboardWillHideNotification
                                             object:nil];
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupNavigationBar
{
  self.navigationItem.title = kAppName;
  
  UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"ActionSheetSave", @"")
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(save)];
  self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)setupSpeechRecognizer
{
  NSString *initString = [NSString stringWithFormat:@"%@=%@", [IFlySpeechConstant APPID], kIFlyAppID];
  
  [IFlySpeechUtility createUtility:initString];
  _iflyRecognizerView = [[IFlyRecognizerView alloc] initWithCenter:self.view.center];
  _iflyRecognizerView.delegate = self;
  
  [_iflyRecognizerView setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
  [_iflyRecognizerView setParameter:@"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
  [_iflyRecognizerView setParameter:@"plain" forKey:[IFlySpeechConstant RESULT_TYPE]];
}


- (void)initComps
{
  CGRect frame = CGRectMake(kHorizontalMargin, kViewOriginY, self.view.frame.size.width - kHorizontalMargin * 2, kTextFieldHeight);
  _titleTextField = [[UITextField alloc] initWithFrame:frame];
  if (_note) {
    _titleTextField.text = _note.title;
  } else {
    _titleTextField.placeholder = @"标题";
  }
  [self.view addSubview:_titleTextField];
  
  UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(kHorizontalMargin, kViewOriginY + kTextFieldHeight, self.view.frame.size.width - kHorizontalMargin, 1)];
  lineView.backgroundColor = [UIColor orangeColor];
  [self.view addSubview:lineView];

  CGFloat textY = kViewOriginY + kTextFieldHeight + kVerticalMargin;
  frame = CGRectMake(kHorizontalMargin,
                     textY,
                     self.view.frame.size.width - kHorizontalMargin * 2,
                     self.view.frame.size.height - textY - kButtonHeight * 2 - kVerticalMargin * 2);
  _contentTextView = [[UITextView alloc] initWithFrame:frame];
  _contentTextView.font = [UIFont systemFontOfSize:15];
  _contentTextView.autocorrectionType = UITextAutocorrectionTypeNo;
  _contentTextView.autocapitalizationType = UITextAutocapitalizationTypeNone;
  [_contentTextView setScrollEnabled:YES];
  if (_note) {
    _contentTextView.text = _note.content;
  } else {
    _contentTextView.text = @"正文";
  }
  UIBarButtonItem *barButton = [[UIBarButtonItem alloc]
                                initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                target:self
                                action:@selector(hideKeyboard)];
  UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kToolbarHeight)];
  toolbar.items = [NSArray arrayWithObject:barButton];
  _contentTextView.inputAccessoryView = toolbar;
  [self.view addSubview:_contentTextView];
  
  
  _emailButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [_emailButton setFrame:CGRectMake(kVoiceButtonWidth, self.view.frame.size.height - kButtonHeight * 2,
                                    self.view.frame.size.width - kVoiceButtonWidth, kButtonHeight)];
  [_emailButton setTitle:NSLocalizedString(@"ActionSheetMail", @"") forState:UIControlStateNormal];
  [_emailButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  [_emailButton setBackgroundColor:[UIColor orangeColor]];
  [_emailButton addTarget:self action:@selector(sendEmail) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:_emailButton];
  
  _weixinButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [_weixinButton setFrame:CGRectMake(kVoiceButtonWidth, self.view.frame.size.height - kButtonHeight, self.view.frame.size.width - kVoiceButtonWidth, kButtonHeight)];
  [_weixinButton setTitle:NSLocalizedString(@"ActionSheetWeixin", @"") forState:UIControlStateNormal];
  [_weixinButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  [_weixinButton setBackgroundColor:[UIColor greenColor]];
  [_weixinButton addTarget:self action:@selector(shareToWeixin) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:_weixinButton];
  
  _voiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [_voiceButton setFrame:CGRectMake(0, self.view.frame.size.height - kButtonHeight * 2, kVoiceButtonWidth, kButtonHeight * 2)];
  [_voiceButton setTitle:NSLocalizedString(@"VoiceInput", @"") forState:UIControlStateNormal];
  [_voiceButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  [_voiceButton setBackgroundColor:[UIColor redColor]];
  [_voiceButton addTarget:self action:@selector(startListenning) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:_voiceButton];
}

- (void)viewWillDisappear:(BOOL)animated
{
  [IFlySpeechUtility destroy];
}

- (void)startListenning
{
  [_iflyRecognizerView start];
  NSLog(@"start listenning...");
}

#pragma mark IFlyRecognizerViewDelegate

- (void)onResult:(NSArray *)resultArray isLast:(BOOL)isLast
{
  NSMutableString *result = [[NSMutableString alloc] init];
  NSDictionary *dic = [resultArray objectAtIndex:0];
  for (NSString *key in dic) {
    [result appendFormat:@"%@", key];
  }
  _contentTextView.text = [NSString stringWithFormat:@"%@%@", _contentTextView.text, result];
}

- (void)onError:(IFlySpeechError *)error
{
  NSLog(@"errorCode:%@", [error errorDesc]);
}


#pragma mark - Keyboard

- (void)keyboardWillShow:(NSNotification *)notification
{
  NSDictionary *userInfo = notification.userInfo;
  [UIView animateWithDuration:[userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                        delay:0.f
                      options:[userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]
                   animations:^
   {
     CGRect keyboardFrame = [[userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
     CGFloat keyboardHeight = keyboardFrame.size.height;
     
     CGRect frame = _contentTextView.frame;
     frame.size.height = self.view.frame.size.height - kViewOriginY - kTextFieldHeight - keyboardHeight - kVerticalMargin - kToolbarHeight,
     _contentTextView.frame = frame;
   }               completion:NULL];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
  NSDictionary *userInfo = notification.userInfo;
  [UIView animateWithDuration:[userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                        delay:0.f
                      options:[userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]
                   animations:^
   {
     CGRect frame = _contentTextView.frame;
     frame.size.height = self.view.frame.size.height - kViewOriginY - kTextFieldHeight - kButtonHeight * 2 - kVerticalMargin * 3;
     _contentTextView.frame = frame;
   }               completion:NULL];
}

- (void)hideKeyboard
{
  if ([_titleTextField isFirstResponder]) {
    [_titleTextField resignFirstResponder];
  }
  if ([_contentTextView isFirstResponder]) {
    [_contentTextView resignFirstResponder];
  }
}

#pragma mark - Save

- (void)save
{
  [self hideKeyboard];
  NSDate *createDate;
  if (_note && _note.createdDate) {
    createDate = _note.createdDate;
  } else {
    createDate = [NSDate date];
  }
  VNNote *note = [[VNNote alloc] initWithTitle:_titleTextField.text
                                       content:_contentTextView.text
                                   createdDate:createDate];
  _note = note;
  BOOL success = [note Persistence];
  if (success) {
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"SaveSuccess", @"")];
  } else {
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"SaveFail", @"")];
  }
}

#pragma mark - Eail

- (void)sendEmail
{
  MFMailComposeViewController *composer = [[MFMailComposeViewController alloc]init];
  [composer setMailComposeDelegate:self];
  if ([MFMailComposeViewController canSendMail]) {
    [composer setSubject:_titleTextField.text];
    [composer setMessageBody:_contentTextView.text isHTML:NO];
    [composer setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:composer animated:YES completion:nil];
  } else {
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"CanNoteSendMail", @"")];
  }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
  if (result == MFMailComposeResultFailed) {
    [self dismissViewControllerAnimated:YES completion:nil];
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"SendEmailFail", @"")];
  } else if (result == MFMailComposeResultSent){
    [self dismissViewControllerAnimated:YES completion:nil];
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"SendEmailSuccess", @"")];
  }
}

#pragma mark - Weixin

- (void)shareToWeixin
{

}

@end
