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
#import "SVProgressHUD.h"
#import "VNNote.h"
@import MessageUI;

static const CGFloat kButtonHeight = 100;

static const CGFloat kTextViewHeight = 320;
static const CGFloat kToolbarHeight = 30;

@interface HomeController ()<IFlyRecognizerViewDelegate, UIActionSheetDelegate,
MFMailComposeViewControllerDelegate, UIAlertViewDelegate>
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

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillShow:)
                                               name:UIKeyboardWillShowNotification
                                             object:nil];

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillHide:)
                                               name:UIKeyboardWillHideNotification
                                             object:nil];
}

- (void)setupNavigationBar
{
  self.navigationItem.title = kAppName;
  UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_more_white"]
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(moreActionButtonPressed)];
  self.navigationItem.rightBarButtonItem = rightItem;

  UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"edit_file"]
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(gotoListView)];
  self.navigationItem.leftBarButtonItem = leftItem;
}

- (void)initComps
{
  _textView = [[UITextView alloc] initWithFrame:CGRectMake(kHorizontalMargin,
                                                           0,
                                                           self.view.frame.size.width - kHorizontalMargin * 2,
                                                           kTextViewHeight)];
  [_textView setFont:[UIFont systemFontOfSize:14]];
  [_textView setEditable:YES];
  [_textView setScrollEnabled:YES];

  UIBarButtonItem *barButton = [[UIBarButtonItem alloc]
                                initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                     target:self action:@selector(hideKeyboard)];

  UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kToolbarHeight)];
  toolbar.items = [NSArray arrayWithObject:barButton];
  _textView.inputAccessoryView = toolbar;

  [self.view addSubview:_textView];

  UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                              kTextViewHeight + kVerticalMargin,
                                                              self.view.frame.size.width,
                                                              1.0f)];
  [lineView setBackgroundColor:[UIColor orangeColor]];
  [self.view addSubview:lineView];

  _recognizeButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [_recognizeButton setFrame:CGRectMake((self.view.frame.size.width - kButtonHeight) / 2,
                                        kTextViewHeight + kVerticalMargin * 4,
                                        kButtonHeight,
                                        kButtonHeight)];
  [_recognizeButton setBackgroundColor:[UIColor redColor]];
  _recognizeButton.layer.cornerRadius = kButtonHeight / 2;
  _recognizeButton.layer.masksToBounds = YES;
  [_recognizeButton addTarget:self action:@selector(startListenning) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:_recognizeButton];
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

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
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
  _textView.text = [NSString stringWithFormat:@"%@%@", _textView.text, result];
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

     CGRect frame = _textView.frame;
     frame.size.height = MIN(self.view.frame.size.height - keyboardHeight - 64, kTextViewHeight);
     _textView.frame = frame;
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
     CGRect frame = _textView.frame;
     frame.size.height = kTextViewHeight;
     _textView.frame = frame;
   }               completion:NULL];
}

- (void)hideKeyboard
{
  if ([_textView isFirstResponder]) {
    [_textView resignFirstResponder];
  }
}

#pragma mark - Action

- (void)gotoListView
{
  if ([_textView isFirstResponder]) {
    [_textView resignFirstResponder];
  }
  NoteListController *listController = [[NoteListController alloc] init];
  [self.navigationController pushViewController:listController animated:YES];
}

#pragma mark - More Action

- (void)moreActionButtonPressed
{
  [self hideKeyboard];
  UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"ActionSheetCancel", @"")
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedString(@"ActionSheetSave", @""), NSLocalizedString(@"ActionSheetMail", @""),
                                NSLocalizedString(@"ActionSheetWeixin", @""), nil];
  [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if (buttonIndex == 0) {
    [self addTitleForNote];
  } else if (buttonIndex == 1) {
    if ([MFMailComposeViewController canSendMail]) {
      [self sendEmail];
    }
  } else if (buttonIndex == 2) {
    NSLog(@"朋友圈");
  }
}

#pragma mark - Save

- (void)addTitleForNote
{
  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AddTitleForNote", @"")
                                                  message:nil
                                                 delegate:self
                                        cancelButtonTitle:NSLocalizedString(@"Sure", @"")
                                        otherButtonTitles:nil];
  alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
  [alertView show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
  NSString *title = [alertView textFieldAtIndex:0].text;
  NSString *content = _textView.text;
  NSDate *createdDate = [NSDate date];
  VNNote *note = [[VNNote alloc] initWithTitle:title
                                       content:content
                                   createdDate:createdDate];
  [note Persistence];
}

#pragma mark - Eail

- (void)sendEmail
{
  MFMailComposeViewController *composer = [[MFMailComposeViewController alloc]init];
  [composer setMailComposeDelegate:self];
  if ([MFMailComposeViewController canSendMail]) {
    [composer setSubject:@""];
    [composer setMessageBody:_textView.text isHTML:NO];
    [composer setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:composer animated:YES completion:nil];
  } else {
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"CanNoteSendMail", @"")];
  }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
  if (error) {
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"SendEmailFail", @"")];
    [self dismissViewControllerAnimated:YES completion:nil];
  } else {
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"SendEmailSuccess", @"")];
    [self dismissViewControllerAnimated:YES completion:nil];
  }
}

@end
