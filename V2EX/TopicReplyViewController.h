//
//  TopicReplyViewController.h
//  V2EX · 读
//
//  Created by St.Jimmy on 2/26/16.
//  Copyright © 2016 Xing He. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentTableViewController.h"

@interface TopicReplyViewController : UIViewController

@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, copy) NSString *repUsrID;
@property (nonatomic, retain) UIView *topicView;
@property (nonatomic, retain) UITableView *topicTableView;
@property (nonatomic, retain) ContentTableViewController *contentTableViewController;

@end
