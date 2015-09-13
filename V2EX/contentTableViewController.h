//
//  contentTableViewController.h
//  V2EX
//
//  Created by St.Jimmy on 5/24/15.
//  Copyright (c) 2015 Xing He. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "SVWebViewController.h"

@interface contentTableViewController : ViewController <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIWebViewDelegate>

@property (nonatomic, strong) NSDictionary *contentAssets;
@property (nonatomic) CGFloat contentViewHeight;
@property NSMutableDictionary *estimatedRowHeightCache;

@property (nonatomic, strong) NSString *exchangeID;

@end
