//
//  AppDelegate.m
//  Voice2Note
//
//  Created by liaojinxing on 14-6-11.
//  Copyright (c) 2014年 jinxing. All rights reserved.
//

#import "AppDelegate.h"
#import "NoteListController.h"
#import "VNConstants.h"
#import "WXApi.h"
#import "Colours.h"
#import "VNNote.h"
#import "VNNoteManager.h"
#import "UIColor+VNHex.h"
#import "MobClick.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  [self addInitFileIfNeeded];
  // Override point for customization after application launch.
  self.window.backgroundColor = [UIColor whiteColor];

  NoteListController *controller = [[NoteListController alloc] init];
  UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
  
  /* customize navigation style */
  [[UINavigationBar appearance] setBarTintColor:[UIColor systemColor]];
  [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
  NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                             [UIColor whiteColor],NSForegroundColorAttributeName,
                                              nil];
  [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
  
  [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
  
  self.window.rootViewController = navigationController;

  [self.window makeKeyAndVisible];
  
  [WXApi registerApp:kWeixinAppID];
  
  [MobClick startWithAppkey:@"53c7945356240bd36002dabe" reportPolicy:BATCH channelId:nil];

  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (void)addInitFileIfNeeded
{
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  if (![userDefaults objectForKey:@"hasInitFile"]) {
    VNNote *note = [[VNNote alloc] initWithTitle:NSLocalizedString(@"AboutTitle", @"")
                                         content:NSLocalizedString(@"AboutText", @"")
                                     createdDate:[NSDate date]
                                      updateDate:[NSDate date]];
    [[VNNoteManager sharedManager] storeNote:note];
    [userDefaults setBool:YES forKey:@"hasInitFile"];
    [userDefaults synchronize];
  }
}

@end
