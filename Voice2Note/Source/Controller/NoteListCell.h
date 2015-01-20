//
//  NoteListCell.h
//  Voice2Note
//
//  Created by liaojinxing on 14-6-12.
//  Copyright (c) 2014年 jinxing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VNNote.h"

@interface NoteListCell : UITableViewCell

@property (nonatomic, assign) NSInteger index;

+ (CGFloat)heightWithNote:(VNNote *)note;
- (void)updateWithNote:(VNNote *)note;

@end
