//
//  ViewController.h
//  V2EX
//
//  Created by St.Jimmy on 5/12/15.
//  Copyright (c) 2015 Xing He. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *myObject;
@property (nonatomic, copy) NSDictionary *dictionary;
@property (nonatomic, copy) NSString *item;
@property (nonatomic, copy) NSString *memAvatar;
@property (nonatomic, copy) NSString *node;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *lastDate;
@property (nonatomic, copy) NSString *replies;
@property (nonatomic, copy) NSString *date;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *titleID;
@property (nonatomic, copy) NSString *URLID;

// Bar Item
@property (weak, nonatomic) IBOutlet UIImageView *selfAvatar;

@property (nonatomic, copy) NSString *naviTitleName;
@property (nonatomic, copy) NSString *tabName;

@property (nonatomic, strong) NSMutableString *contentTitle;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@end

