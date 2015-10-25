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
@property (nonatomic, strong) NSString *item;
@property (nonatomic, strong) NSString *memAvatar;
@property (nonatomic, strong) NSString *node;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *lastDate;
@property (nonatomic, strong) NSString *replies;
@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *titleID;
@property (nonatomic, strong) NSString *URLID;

// Bar Item
@property (weak, nonatomic) IBOutlet UIImageView *selfAvatar;

@property (nonatomic, strong) NSString *naviTitleName;
@property (nonatomic, strong) NSString *tabName;

@property (nonatomic, strong) NSMutableString *contentTitle;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@end

