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
#import "iflyMSC/IFlyDataUploader.h"
#import "iflyMSC/IFlyContact.h"
#import "WXApi.h"
#import "Colours.h"
#import "UIColor+VNHex.h"
#import "AppContext.h"
#import "MobClick.h"
@import MessageUI;

static const CGFloat kViewOriginY = 70;
static const CGFloat kTextFieldHeight = 30;
static const CGFloat kToolbarHeight = 44;
static const CGFloat kVoiceButtonWidth = 100;

@interface NoteDetailController () <IFlyRecognizerViewDelegate, UIActionSheetDelegate,
                                    MFMailComposeViewControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate>
{
  VNNote *_note;
  UITextField *_titleTextField;
  UITextView *_contentTextView;

  UIButton *_voiceButton;
  IFlyRecognizerView *_iflyRecognizerView;
  BOOL _isEditingTitle;
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
  [self.view setBackgroundColor:[UIColor whiteColor]];

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
  UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"ActionSheetSave", @"")
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(save)];

  UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_more_white"]
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(moreActionButtonPressed)];
  self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:moreItem, saveItem, nil];
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

  UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(hideKeyboard)];
  doneBarButton.width = ceilf(self.view.frame.size.width) / 3 - 30;

  UIBarButtonItem *voiceBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"micro_small"] style:UIBarButtonItemStylePlain target:self action:@selector(useVoiceInput)];
  voiceBarButton.width = ceilf(self.view.frame.size.width) / 3;

  UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kToolbarHeight)];
  toolbar.tintColor = [UIColor systemColor];
  toolbar.items = [NSArray arrayWithObjects:doneBarButton, voiceBarButton, nil];

  _titleTextField = [[UITextField alloc] initWithFrame:frame];
  if (_note) {
    _titleTextField.text = _note.title;
  } else {
    _titleTextField.placeholder = NSLocalizedString(@"InputViewTitle", @"");
  }
  _titleTextField.textColor = [UIColor systemDarkColor];
  _titleTextField.inputAccessoryView = toolbar;
  [self.view addSubview:_titleTextField];

  UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(kHorizontalMargin, kViewOriginY + kTextFieldHeight, self.view.frame.size.width - kHorizontalMargin, 1)];
  lineView.backgroundColor = [UIColor systemDarkColor];
  [self.view addSubview:lineView];

  CGFloat textY = kViewOriginY + kTextFieldHeight + kVerticalMargin;
  frame = CGRectMake(kHorizontalMargin,
                     textY,
                     self.view.frame.size.width - kHorizontalMargin * 2,
                     self.view.frame.size.height - textY - kVoiceButtonWidth - kVerticalMargin * 2);
  _contentTextView = [[UITextView alloc] initWithFrame:frame];
  _contentTextView.textColor = [UIColor systemDarkColor];
  _contentTextView.font = [UIFont systemFontOfSize:16];
  _contentTextView.autocorrectionType = UITextAutocorrectionTypeNo;
  _contentTextView.autocapitalizationType = UITextAutocapitalizationTypeNone;
  [_contentTextView setScrollEnabled:YES];
  if (_note) {
    _contentTextView.text = _note.content;
  }
  _contentTextView.inputAccessoryView = toolbar;
  [self.view addSubview:_contentTextView];

  _voiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [_voiceButton setFrame:CGRectMake((self.view.frame.size.width - kVoiceButtonWidth) / 2, self.view.frame.size.height - kVoiceButtonWidth - kVerticalMargin, kVoiceButtonWidth, kVoiceButtonWidth)];
  [_voiceButton setTitle:NSLocalizedString(@"VoiceInput", @"") forState:UIControlStateNormal];
  [_voiceButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  _voiceButton.layer.cornerRadius = kVoiceButtonWidth / 2;
  _voiceButton.layer.masksToBounds = YES;
  [_voiceButton setBackgroundColor:[UIColor systemColor]];
  [_voiceButton addTarget:self action:@selector(useVoiceInput) forControlEvents:UIControlEventTouchUpInside];
  [_voiceButton setTintColor:[UIColor whiteColor]];
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

- (void)useVoiceInput
{
  if (![AppContext appContext].hasUploadAddressBook) {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:NSLocalizedString(@"UploadABForBetter", @"")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"ActionSheetCancel", @"")
                                              otherButtonTitles:NSLocalizedString(@"GotoUploadAB", @""), nil];
    [alertView show];
    [[AppContext appContext] setHasUploadAddressBook:YES];
    return;
  }
  
  [self hideKeyboard];
  [self startListenning];
  [MobClick event:kEventClickVoiceButton];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if (buttonIndex == 1) {
    IFlyDataUploader *_uploader = [[IFlyDataUploader alloc] init];
    IFlyContact *iFlyContact = [[IFlyContact alloc] init]; NSString *contactList = [iFlyContact contact];
    [_uploader setParameter:@"uup" forKey:@"subject"];
    [_uploader setParameter:@"contact" forKey:@"dtt"];
    //启动上传
    [_uploader uploadDataWithCompletionHandler:^(NSString *grammerID, IFlySpeechError *error) {
      [SVProgressHUD showSuccessWithStatus:@"上传成功"];
    } name:@"contact" data:contactList];
  }
}

#pragma mark IFlyRecognizerViewDelegate

- (void)onResult:(NSArray *)resultArray isLast:(BOOL)isLast
{
  NSMutableString *result = [[NSMutableString alloc] init];
  NSDictionary *dic = [resultArray objectAtIndex:0];
  for (NSString *key in dic) {
    [result appendFormat:@"%@", key];
  }
  if (_isEditingTitle) {
    _titleTextField.text = [NSString stringWithFormat:@"%@%@", _titleTextField.text, result];
  } else {
    _contentTextView.text = [NSString stringWithFormat:@"%@%@", _contentTextView.text, result];
  }
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
     frame.size.height = self.view.frame.size.height - kViewOriginY - kTextFieldHeight - kVoiceButtonWidth - kVerticalMargin * 3;
     _contentTextView.frame = frame;
   }               completion:NULL];
}

- (void)hideKeyboard
{
  if ([_titleTextField isFirstResponder]) {
    _isEditingTitle = YES;
    [_titleTextField resignFirstResponder];
  }
  if ([_contentTextView isFirstResponder]) {
    _isEditingTitle = NO;
    [_contentTextView resignFirstResponder];
  }
}

#pragma mark - Save

- (void)save
{
  [self hideKeyboard];
  if ((_contentTextView.text == nil || _contentTextView.text.length == 0) &&
      (_titleTextField.text == nil || _titleTextField.text.length == 0)) {
    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"InputTextNoData", @"")];
    return;
  }
  NSDate *createDate;
  if (_note && _note.createdDate) {
    createDate = _note.createdDate;
  } else {
    createDate = [NSDate date];
  }
  VNNote *note = [[VNNote alloc] initWithTitle:_titleTextField.text
                                       content:_contentTextView.text
                                   createdDate:createDate
                                    updateDate:[NSDate date]];
  _note = note;
  BOOL success = [note Persistence];
  if (success) {
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"SaveSuccess", @"")];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCreateFile object:nil userInfo:nil];
  } else {
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"SaveFail", @"")];
  }
  [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - More Action

- (void)moreActionButtonPressed
{
  [self hideKeyboard];
  UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"ActionSheetCancel", @"")
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedString(@"ActionSheetCopy", @""),
                                NSLocalizedString(@"ActionSheetMail", @""),
                                NSLocalizedString(@"ActionSheetWeixin", @""), nil];
  [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if (buttonIndex == 0) {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = _contentTextView.text;
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"CopySuccess", @"")];
  } else if (buttonIndex == 1) {
    if ([MFMailComposeViewController canSendMail]) {
      [self sendEmail];
    }
  } else if (buttonIndex == 2) {
    [self shareToWeixin];
  }
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
  for (UIView *subview in actionSheet.subviews) {
    if ([subview isKindOfClass:[UIButton class]]) {
      UIButton *button = (UIButton *)subview;
      [button setTitleColor:[UIColor systemColor] forState:UIControlStateNormal];
    }
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
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"SendEmailFail", @"")];
  } else if (result == MFMailComposeResultSent) {
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"SendEmailSuccess", @"")];
  }
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Weixin

- (void)shareToWeixin
{
  if (_contentTextView.text == nil || _contentTextView.text.length == 0) {
    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"InputTextNoData", @"")];
    return;
  }

  SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
  req.text = _contentTextView.text;
  req.bText = YES;
  req.scene = WXSceneTimeline;
  [WXApi sendReq:req];
  [MobClick event:kEventShareToWeixin];
}

@end
