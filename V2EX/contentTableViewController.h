//
//  contentTableViewController.h
//  V2EX
//
//  Created by St.Jimmy on 5/24/15.
//  Copyright (c) 2015 Xing He. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface contentTableViewController : ViewController <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>

@property (nonatomic, strong) NSDictionary *contentAssets;
@property (nonatomic) CGFloat contentViewHeight;

@end
