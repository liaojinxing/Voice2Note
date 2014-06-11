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
@import MessageUI;

@interface NoteDetailController () <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>
{
  VNNote *_note;
  UITextField *_titleTextField;
  UITextView *_contentTextView;
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
}

- (void)setupNavigationBar
{
  UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_more_white"]
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(moreActionButtonPressed)];
  self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)initComps
{
  CGRect frame = CGRectMake(kHorizontalMargin, 70, self.view.frame.size.width - kHorizontalMargin * 2, 30);
  _titleTextField = [[UITextField alloc] initWithFrame:frame];
  _titleTextField.clipsToBounds = YES;
  _titleTextField.layer.cornerRadius = 3.0f;
  _titleTextField.layer.borderWidth = 0.5f;
  _titleTextField.layer.borderColor = [UIColor grayColor].CGColor;
  _titleTextField.text = _note.title;
  [self.view addSubview:_titleTextField];
  
  frame = CGRectMake(kHorizontalMargin, 110, self.view.frame.size.width - kHorizontalMargin * 2, 200);
  _contentTextView = [[UITextView alloc] initWithFrame:frame];
  _contentTextView.autocorrectionType = UITextAutocorrectionTypeNo;
  _contentTextView.autocapitalizationType = UITextAutocapitalizationTypeNone;
  _contentTextView.clipsToBounds = YES;
  _contentTextView.layer.cornerRadius = 3.0f;
  [_contentTextView setScrollEnabled:YES];
  _contentTextView.layer.borderWidth = 0.5f;
  _contentTextView.layer.borderColor = [UIColor grayColor].CGColor;
  _contentTextView.text = _note.content;
  [self.view addSubview:_contentTextView];
}

#pragma mark - More Action

- (void)moreActionButtonPressed
{
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
    [self save];
  } else if (buttonIndex == 1) {
    if ([MFMailComposeViewController canSendMail]) {
      [self sendEmail];
    }
  } else if (buttonIndex == 2) {
    NSLog(@"朋友圈");
  }
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
  VNNote *note = [[VNNote alloc] initWithTitle:_titleTextField.text
                                       content:_contentTextView.text
                                   createdDate:_note.createdDate];
  [note Persistence];
}

#pragma mark - Eail

- (void)sendEmail
{
  MFMailComposeViewController *composer = [[MFMailComposeViewController alloc]init];
  [composer setMailComposeDelegate:self];
  if ([MFMailComposeViewController canSendMail]) {
    [composer setSubject:@""];
    [composer setMessageBody:_contentTextView.text isHTML:NO];
    [composer setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:composer animated:YES completion:nil];
  } else {
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"CanNoteSendMail", @"")];
  }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
  if (error) {
    [self dismissViewControllerAnimated:YES completion:nil];
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"SendEmailFail", @"")];
  } else {
    [self dismissViewControllerAnimated:YES completion:nil];
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"SendEmailSuccess", @"")];
  }
}


@end
