//
//  contentTableViewController.h
//  V2EX
//
//  Created by St.Jimmy on 5/24/15.
//  Copyright (c) 2015 Xing He. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "TTTAttributedLabel.h"
#import "LoginViewController.h"

@import SafariServices;

@interface ContentTableViewController : ViewController <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIWebViewDelegate, SFSafariViewControllerDelegate, UIViewControllerPreviewingDelegate, TTTAttributedLabelDelegate>

@property (nonatomic, copy) NSDictionary *contentAssets;
@property (nonatomic) CGFloat contentViewHeight;
@property NSMutableDictionary *estimatedRowHeightCache;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;
@property (nonatomic, retain) LoginViewController *loginViewController;

@property (nonatomic, copy) NSString *exchangeID;

- (void)showBannerAlertViewWithView:(UIView *)view;

@end
