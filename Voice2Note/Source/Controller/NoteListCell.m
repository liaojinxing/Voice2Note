//
//  NoteListCell.m
//  Voice2Note
//
//  Created by liaojinxing on 14-6-12.
//  Copyright (c) 2014年 jinxing. All rights reserved.
//

#import "NoteListCell.h"
#import "UIColor+VNHex.h"
#import "VNConstants.h"
#import "Colours.h"

static const CGFloat kCellHorizontalMargin = 0;
static const CGFloat kCellPadding = 15;
static const CGFloat kVerticalPadding = 0;
static const CGFloat kLabelHeight = 15;

static const CGFloat kMaxTitleHeight = 180;

@interface NoteListCell ()
{
  UIView *_backgroundView;
  UILabel *_titleLabel;
  UILabel *_timeLabel;
}

@end

@implementation NoteListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    self.backgroundColor = [UIColor systemColor];
    self.contentView.backgroundColor = [UIColor systemColor];
    _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(kCellHorizontalMargin,
                                                               kVerticalPadding,
                                                               [UIScreen mainScreen].bounds.size.width - kCellHorizontalMargin * 2,
                                                               0)];
    _backgroundView.layer.cornerRadius = 0.0f;
    _backgroundView.layer.masksToBounds = YES;
    [_backgroundView setBackgroundColor:[UIColor grayBackgroudColor]];
    [self.contentView addSubview:_backgroundView];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kCellPadding, kCellPadding, _backgroundView.frame.size.width - kCellPadding * 2, 0)];
    [_titleLabel setTextColor:[UIColor charcoalColor]];
    [_titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [_titleLabel setNumberOfLines:0];
    [_backgroundView addSubview:_titleLabel];
    
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kCellPadding, kCellPadding, _backgroundView.frame.size.width - kCellPadding * 2, kLabelHeight)];
    [_timeLabel setTextColor:[UIColor charcoalColor]];
    [_timeLabel setFont:[UIFont systemFontOfSize:10]];
    [_timeLabel setTextAlignment:NSTextAlignmentRight];
    [_backgroundView addSubview:_timeLabel];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
  }
  return self;
}

- (void)updateWithNote:(VNNote *)note
{
  NSString *string = note.title;
  [_titleLabel setText:note.title];
  if (!note.title || note.title.length <= 0 || [note.title isEqualToString:NSLocalizedString(@"NoTitleNote", @"")]) {
    string = note.content;
    [_titleLabel setText:note.content];
  }
  CGFloat titleHeight = [[self class] heightWithString:string
                                                width:_backgroundView.frame.size.width - kCellPadding * 2];
  CGRect titleFrame = _titleLabel.frame;
  titleFrame.size.height = titleHeight;
  _titleLabel.frame = titleFrame;
  
  CGRect timeFrame = _timeLabel.frame;
  timeFrame.origin.y = kCellPadding + titleHeight;
  _timeLabel.frame = timeFrame;
  
  CGRect bgFrame = _backgroundView.frame;
  bgFrame.size.height = [[self class] heightWithNote:note] - kVerticalPadding * 2;
  _backgroundView.frame = bgFrame;

  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
  [_timeLabel setText:[formatter stringFromDate:note.createdDate]];
}

+ (CGFloat)heightWithNote:(VNNote *)note
{
  CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
  NSString *string = note.title;
  if (!note.title || note.title.length <= 0 || [note.title isEqualToString:NSLocalizedString(@"NoTitleNote", @"")]) {
    string = note.content;
  }
  CGFloat titleHeight = [[self class] heightWithString:string width:screenWidth - kCellHorizontalMargin * 2 - kCellPadding * 2];
  return  kVerticalPadding + kCellPadding + titleHeight + kLabelHeight + kCellPadding + kVerticalPadding;
}

+ (CGFloat)heightWithString:(NSString *)string width:(CGFloat)width
{
  NSDictionary *attributes = @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:17] };
  CGSize size = [string boundingRectWithSize:CGSizeMake(width, kMaxTitleHeight)
                                    options:NSStringDrawingUsesLineFragmentOrigin
                                 attributes:attributes
                                    context:nil].size;
  return ceilf(size.height);
}

@end
