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

static const CGFloat kCellPadding = 8;
static const CGFloat kVerticalPadding = 6;
static const CGFloat kLabelHeight = 15;

@interface NoteListCell ()
{
  UIView *_backgroundView;
  UILabel *_titleLabel;
  UILabel *_timeLabel;
}

@property (nonatomic, strong) NSArray *colorArray;

@end

@implementation NoteListCell

- (NSArray *)colorArray
{
  if (!_colorArray) {
    NSMutableArray  * array= [NSMutableArray arrayWithObjects:[UIColor colorWithHex:0xa9d8e8],
                              [UIColor colorWithHex:0x0789ba],
                              [UIColor colorWithHex:0xffbe26],
                              [UIColor colorWithHex:0xb28850],
                              [UIColor colorWithHex:0xe57367],
                              [UIColor colorWithHex:0xbc5779],
                              [UIColor colorWithHex:0x64b043],
                              [UIColor colorWithHex:0xd9e26d],
                              nil];

    _colorArray = [NSArray arrayWithArray:array];
  }
  return _colorArray;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(kHorizontalMargin,
                                                               kVerticalMargin,
                                                               self.frame.size.width - kHorizontalMargin * 2,
                                                               0)];
    [self.contentView addSubview:_backgroundView];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kCellPadding, kCellPadding, _backgroundView.frame.size.width - kCellPadding * 2, 0)];
    [_titleLabel setTextColor:[UIColor whiteColor]];
    [_titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [_titleLabel setNumberOfLines:0];
    [_backgroundView addSubview:_titleLabel];
    
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kCellPadding, kCellPadding, _backgroundView.frame.size.width - kCellPadding * 2, kLabelHeight)];
    [_timeLabel setTextColor:[UIColor whiteColor]];
    [_timeLabel setFont:[UIFont systemFontOfSize:10]];
    [_timeLabel setTextAlignment:NSTextAlignmentRight];
    [_backgroundView addSubview:_timeLabel];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
  }
  return self;
}

- (void)updateWithNote:(VNNote *)note
{
  CGFloat titleHeight = [[self class] heightWithTitle:note.title
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
  
  NSTimeInterval interval = [note.createdDate timeIntervalSince1970];
  int index = (int)interval % self.colorArray.count;
  UIColor *bgColor = [self.colorArray objectAtIndex:index];
  [_backgroundView setBackgroundColor:bgColor];
  
  [_titleLabel setText:note.title];
  
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
  [_timeLabel setText:[formatter stringFromDate:note.createdDate]];
}

+ (CGFloat)heightWithNote:(VNNote *)note
{
  CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
  CGFloat titleHeight = [[self class] heightWithTitle:note.title width:screenWidth - kHorizontalMargin * 2 - kCellPadding * 2];
  return kCellPadding + titleHeight + kLabelHeight + kCellPadding + kVerticalPadding * 2;
}

+ (CGFloat)heightWithTitle:(NSString *)title width:(CGFloat)width
{
  NSDictionary *attributes = @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:16] };
  CGSize size = [title boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                    options:NSStringDrawingUsesLineFragmentOrigin
                                 attributes:attributes
                                    context:nil].size;
  return ceilf(size.height);
}

@end
