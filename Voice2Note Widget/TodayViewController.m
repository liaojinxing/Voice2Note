//
//  TodayViewController.m
//  Voice2Note Widget
//
//  Created by liaojinxing on 14/11/3.
//  Copyright (c) 2014年 jinxing. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "NoteManager.h"
#import "VNNote.h"

@interface TodayViewController () <NCWidgetProviding>

@property (nonatomic, strong) IBOutlet UILabel *contentLabel;
- (IBAction)gotoAddNote:(id)sender;

@end

@implementation TodayViewController

- (void)viewDidLoad {
  [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
  // Perform any setup necessary in order to update the view.
    
  // If an error is encountered, use NCUpdateResultFailed
  // If there's no update required, use NCUpdateResultNoData
  // If there's an update, use NCUpdateResultNewData
  
  completionHandler(NCUpdateResultNewData);

}

- (IBAction)gotoAddNote:(id)sender
{
    NSExtensionContext *myExtension=[self extensionContext];
    [myExtension openURL:[NSURL URLWithString:@"voice2note://home"] completionHandler:nil];
}

@end
