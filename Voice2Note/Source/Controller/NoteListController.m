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

static const CGFloat kListCellHeight = 44.0f;

@interface NoteListController ()

@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation NoteListController

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self setupNavigationBar];
  
  NSLog(@"%@", self.dataSource);
}

- (void)setupNavigationBar
{
  UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_add_tab"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(createTask)];
  self.navigationItem.rightBarButtonItem = item;
  self.navigationItem.title = @"NoteList";
  
}

- (NSMutableArray *)dataSource
{
  if (!_dataSource) {
    _dataSource = [[VNNoteManager sharedManager] readAllNotes];
  }
  return _dataSource;
}

- (void)createTask
{
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
  return kListCellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListCell"];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ListCell"];
  }
  VNNote *note = [self.dataSource objectAtIndex:indexPath.row];
  cell.textLabel.text = note.title;
  [cell.textLabel setFont:[UIFont boldSystemFontOfSize:17]];
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  VNNote *note = [self.dataSource objectAtIndex:indexPath.row];
  NoteDetailController *controller = [[NoteDetailController alloc] initWithNote:note];
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
