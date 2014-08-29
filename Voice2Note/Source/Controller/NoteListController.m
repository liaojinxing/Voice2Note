//
//  NoteListController.m
//  Voice2Note
//
//  Created by liaojinxing on 14-6-11.
//  Copyright (c) 2014年 jinxing. All rights reserved.
//

#import "NoteListController.h"
#import "VNNoteManager.h"
#import "NoteDetailController.h"
#import "VNNote.h"
#import "VNConstants.h"
#import "NoteListCell.h"
#import "MobClick.h"
#import "iflyMSC/IFlyRecognizerView.h"
#import "iflyMSC/IFlySpeechConstant.h"
#import "iflyMSC/IFlyRecognizerView.h"
#import "iflyMSC/IFlySpeechUtility.h"
#import "SVProgressHUD.h"

@interface NoteListController ()<IFlyRecognizerViewDelegate>
{
  IFlyRecognizerView *_iflyRecognizerView;
  NSMutableString *_resultString;
}
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation NoteListController

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self setupNavigationBar];
  [self setupVoiceRecognizerView];
  self.view.backgroundColor = [UIColor colorWithWhite:0.4 alpha:1.0];
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(reloadData)
                                               name:kNotificationCreateFile
                                             object:nil];
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [IFlySpeechUtility destroy];
}

- (void)setupNavigationBar
{
  UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"micro_small"]
                                                           style:UIBarButtonItemStylePlain
                                                          target:self
                                                          action:@selector(createVoiceTask)];
  self.navigationItem.leftBarButtonItem = leftItem;
  
  UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_add_tab"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(createTask)];
  self.navigationItem.rightBarButtonItem = rightItem;
  self.navigationItem.title = kAppName;
}

- (void)setupVoiceRecognizerView
{
  NSString *initString = [NSString stringWithFormat:@"%@=%@", [IFlySpeechConstant APPID], kIFlyAppID];
  
  [IFlySpeechUtility createUtility:initString];
  _iflyRecognizerView = [[IFlyRecognizerView alloc] initWithCenter:self.view.center];
  _iflyRecognizerView.delegate = self;
  
  [_iflyRecognizerView setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
  [_iflyRecognizerView setParameter:@"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
  [_iflyRecognizerView setParameter:@"plain" forKey:[IFlySpeechConstant RESULT_TYPE]];
  
  _resultString = [NSMutableString string];
}

- (void)reloadData
{
  _dataSource = [[VNNoteManager sharedManager] readAllNotes];
  [self.tableView reloadData];
}

- (NSMutableArray *)dataSource
{
  if (!_dataSource) {
    _dataSource = [[VNNoteManager sharedManager] readAllNotes];
  }
  return _dataSource;
}

- (void)createVoiceTask
{
  [_iflyRecognizerView start];
}

#pragma mark IFlyRecognizerViewDelegate

- (void)onResult:(NSArray *)resultArray isLast:(BOOL)isLast
{
  NSMutableString *result = [[NSMutableString alloc] init];
  NSDictionary *dic = [resultArray objectAtIndex:0];
  for (NSString *key in dic) {
    [result appendFormat:@"%@", key];
  }
  [_resultString appendString:result];
  if (isLast) {
    VNNote *note = [[VNNote alloc] initWithTitle:nil
                                         content:_resultString
                                     createdDate:[NSDate date]
                                      updateDate:[NSDate date]];
    BOOL success = [note Persistence];
    if (success) {
      [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"SaveSuccess", @"")];
      [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCreateFile object:nil userInfo:nil];
    } else {
      [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"SaveFail", @"")];
    }
    _resultString = [NSMutableString string];
  }
}

- (void)onError:(IFlySpeechError *)error
{
  NSLog(@"errorCode:%@", [error errorDesc]);
}

- (void)createTask
{
  [MobClick event:kEventAddNewNote];
  NoteDetailController *controller = [[NoteDetailController alloc] init];
  [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - DataSource & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  VNNote *note = [self.dataSource objectAtIndex:indexPath.row];
  return [NoteListCell heightWithNote:note];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NoteListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListCell"];
  if (!cell) {
    cell = [[NoteListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ListCell"];
  }
  VNNote *note = [self.dataSource objectAtIndex:indexPath.row];
  [cell updateWithNote:note];
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView deselectRowAtIndexPath:indexPath animated:NO];
  VNNote *note = [self.dataSource objectAtIndex:indexPath.row];
  NoteDetailController *controller = [[NoteDetailController alloc] initWithNote:note];
  controller.hidesBottomBarWhenPushed = YES;
  [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - EditMode

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
  return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    VNNote *note = [self.dataSource objectAtIndex:indexPath.row];
    [[VNNoteManager sharedManager] deleteNote:note];
    
    [self.dataSource removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
  }
}

@end
