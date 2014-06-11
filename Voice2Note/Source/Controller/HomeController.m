//
//  HomeController.m
//  Voice2Note
//
//  Created by liaojinxing on 14-6-11.
//  Copyright (c) 2014年 jinxing. All rights reserved.
//

#import "HomeController.h"
#import "NoteListController.h"

static const CGFloat kButtonHeight = 100;
static const CGFloat kHorizontalMargin = 10;
static const CGFloat kVerticalMargin = 10;

@interface HomeController ()
{
  UITextView *_textView;
  UIButton *_recognizeButton;
}

@end

@implementation HomeController

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.navigationItem.title = @"Voice2Note";
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
  
  _recognizeButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [_recognizeButton setFrame:CGRectMake((self.view.frame.size.width - kButtonHeight) / 2,
                                        self.view.frame.size.height - kButtonHeight - kVerticalMargin * 2,
                                        kButtonHeight,
                                        kButtonHeight)];
  [_recognizeButton setBackgroundColor:[UIColor redColor]];
  _recognizeButton.layer.cornerRadius = kButtonHeight / 2;
  _recognizeButton.layer.masksToBounds = YES;
  [_recognizeButton addTarget:self action:@selector(startListering) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:_recognizeButton];
  
  CGFloat y = 70;
  _textView = [[UITextView alloc] initWithFrame:CGRectMake(kHorizontalMargin, y,
                                                           self.view.frame.size.width - kHorizontalMargin * 2,
                                                           _recognizeButton.frame.origin.y - y - kVerticalMargin * 2)];
  [_textView setEditable:YES];
  [_textView setText:@"你说的话将会呈现在这里"];
  [_textView setScrollEnabled:YES];
  [self.view addSubview:_textView];

  UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                             _recognizeButton.frame.origin.y - kVerticalMargin,
                                                              self.view.frame.size.width,
                                                              1.0f)];
  [lineView setBackgroundColor:[UIColor orangeColor]];
  [self.view addSubview:lineView];
}

- (void)startListering
{

}

- (void)moreActionButtonPressed
{

}

- (void)gotoListView
{
  NoteListController *listController = [[NoteListController alloc] init];
  [self.navigationController pushViewController:listController animated:YES];
}

@end
