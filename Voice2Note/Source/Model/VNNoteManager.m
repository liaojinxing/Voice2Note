//
//  VNNoteManager.m
//  Voice2Note
//
//  Created by liaojinxing on 14-6-11.
//  Copyright (c) 2014年 jinxing. All rights reserved.
//

#import "VNNoteManager.h"
#import "VNConstants.h"
#import "VNNote.h"
#import "SVProgressHUD.h"

@implementation VNNoteManager

+ (instancetype)sharedManager
{
  static id instance = nil;
  static dispatch_once_t onceToken = 0L;
  dispatch_once(&onceToken, ^{
    instance = [[super allocWithZone:NULL] init];
  });
  return instance;
}

- (NSString *)createDataPathIfNeeded
{
  NSString *documentsDirectory = [self documentDirectoryPath];
  self.docPath = documentsDirectory;
  
  if ([[NSFileManager defaultManager] fileExistsAtPath:documentsDirectory]) {
    return self.docPath;
  }
  
  NSError *error;
  BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectory
                                           withIntermediateDirectories:YES
                                                            attributes:nil
                                                                 error:&error];
  if (!success) {
    NSLog(@"Error creating data path: %@", [error localizedDescription]);
  }
  return self.docPath;
}

- (NSString *)documentDirectoryPath
{
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  documentsDirectory = [documentsDirectory stringByAppendingPathComponent:kAppEngName];
  return documentsDirectory;
}

- (NSMutableArray *)readAllNotes
{
  NSMutableArray *array = [NSMutableArray array];
  NSError *error;
  NSString *documentsDirectory = [self createDataPathIfNeeded];
  NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:&error];
  
  if (files == nil) {
    NSLog(@"Error reading contents of documents directory: %@", [error localizedDescription]);
    return nil;
  }
  
  // Create Note for each file
  for (NSString *file in files) {
    VNNote *note = [self readNoteWithID:file];
    if (note) {
      [array addObject:note];
    }
  }
  return array;
}

- (VNNote *)readNoteWithID:(NSString *)noteID;
{
  NSString *dataPath = [_docPath stringByAppendingPathComponent:noteID];
  NSData *codedData = [[NSData alloc] initWithContentsOfFile:dataPath];
  if (codedData == nil) {
    return nil;
  }
  VNNote *note = [NSKeyedUnarchiver unarchiveObjectWithData:codedData];
  return note;
}

- (BOOL)storeNote:(VNNote *)note
{
  [self createDataPathIfNeeded];
  NSString *dataPath = [_docPath stringByAppendingPathComponent:note.noteID];
  NSData *savedData = [NSKeyedArchiver archivedDataWithRootObject:note];
  return [savedData writeToFile:dataPath atomically:YES];
}

- (void)deleteNote:(VNNote *)note
{
  NSString *filePath = [_docPath stringByAppendingPathComponent:note.noteID];
  [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
}

@end
