//
//  VNNote.m
//  Voice2Note
//
//  Created by liaojinxing on 14-6-11.
//  Copyright (c) 2014年 jinxing. All rights reserved.
//

#import "VNNote.h"
#import "VNNoteManager.h"

#define kNoteIDKey      @"NoteID"
#define kTitleKey       @"Title"
#define kContentKey     @"Content"
#define kCreatedDate    @"CreatedDate"

@implementation VNNote

@synthesize noteID = _noteID;
@synthesize title = _title;
@synthesize content = _content;
@synthesize createdDate = _createdDate;

- (id)initWithTitle:(NSString *)title
            content:(NSString *)content
        createdDate:(NSDate *)createdDate
{
  self = [super init];
  if (self) {
    _noteID = [NSNumber numberWithDouble:[createdDate timeIntervalSince1970]].stringValue;
    _title = title;
    _content = content;
    _createdDate = createdDate;
    if (_title == nil || _title.length == 0) {
      NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
      [formatter setDateFormat:@"yyMMdd-HH:mm:ss"];
      _title = [formatter stringFromDate:_createdDate];
    }
    if (_content == nil || _content.length == 0) {
      _content = @"";
    }
  }
  return self;
}

- (void) encodeWithCoder:(NSCoder *)encoder {
  [encoder encodeObject:_noteID forKey:kNoteIDKey];
  [encoder encodeObject:_title forKey:kTitleKey];
  [encoder encodeObject:_content forKey:kContentKey];
  [encoder encodeObject:_createdDate forKey:kCreatedDate];
}

- (id)initWithCoder:(NSCoder *)decoder {
  NSString *title = [decoder decodeObjectForKey:kTitleKey];
  NSString *content = [decoder decodeObjectForKey:kContentKey];
  NSDate *createDate = [decoder decodeObjectForKey:kCreatedDate];
  return [self initWithTitle:title
                     content:content
                 createdDate:createDate];
}

- (BOOL)Persistence
{
  return [[VNNoteManager sharedManager] storeNote:self];
}

@end

