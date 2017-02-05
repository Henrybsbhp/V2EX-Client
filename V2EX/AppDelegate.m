//
//  AppDelegate.m
//  V2EX
//
//  Created by St.Jimmy on 5/12/15.
//  Copyright (c) 2015 Xing He. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "contentTableViewController.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "IQKeyboardManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    [IQKeyboardManager sharedManager].enable = NO;
    
    return YES;
}


@end
