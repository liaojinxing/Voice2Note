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

static const CGFloat kCellHorizontalMargin = 4;
static const CGFloat kCellPadding = 8;
static const CGFloat kVerticalPadding = 4;
static const CGFloat kLabelHeight = 15;

static const CGFloat kMaxTitleHeight = 100;

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
    NSMutableArray  * array= [NSMutableArray arrayWithObjects:
                              [UIColor emeraldColor],
                              [UIColor fadedBlueColor],
                              [UIColor cantaloupeColor],
                              [UIColor oliveColor],
                              [UIColor salmonColor],
                              [UIColor easterPinkColor],
                              [UIColor blueberryColor],
                              [UIColor turquoiseColor],
                              [UIColor blueberryColor],
                              [UIColor warmGrayColor],
                              [UIColor tealColor],
                              [UIColor lavenderColor],
                              [UIColor bananaColor],
                              [UIColor cornflowerColor],
                              [UIColor skyBlueColor],
                              [UIColor coralColor],
                              [UIColor sandColor],
                              [UIColor almondColor],
                              [UIColor cardTableColor],
                              [UIColor pastelGreenColor],
                              [UIColor waveColor],
                              [UIColor orchidColor],
                              [UIColor mandarinColor],
                              [UIColor carrotColor],
                              [UIColor orangeColor],
                              [UIColor indianRedColor],
                              [UIColor maroonColor],
                              [UIColor violetColor],
                              [UIColor coolGrayColor],
                              [UIColor hollyGreenColor],
                              [UIColor plumColor],
                              nil];

    _colorArray = [NSArray arrayWithArray:array];
  }
  return _colorArray;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(kCellHorizontalMargin,
                                                               kVerticalMargin,
                                                               self.frame.size.width - kCellHorizontalMargin * 2,
                                                               0)];
    _backgroundView.layer.cornerRadius = 4.0f;
    _backgroundView.layer.masksToBounds = YES;
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
  
  NSTimeInterval interval = [note.createdDate timeIntervalSince1970];
  int index = (int)interval % self.colorArray.count;
  UIColor *bgColor = [self.colorArray objectAtIndex:index];
  [_backgroundView setBackgroundColor:bgColor];
  
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
  return kCellPadding + titleHeight + kLabelHeight + kCellPadding + kVerticalPadding;
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
