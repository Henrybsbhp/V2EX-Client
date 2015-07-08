//
//  contentTableViewCell.h
//  V2EX
//
//  Created by St.Jimmy on 5/24/15.
//  Copyright (c) 2015 Xing He. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface contentTableViewCell : UITableViewCell <UIWebViewDelegate>

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, weak) IBOutlet UILabel *nodeLabel;
@property (nonatomic, weak) IBOutlet UILabel *lzIDLabel;
@property (weak, nonatomic) IBOutlet UIWebView *contentWebView;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *numOfRepLabel;

@property (nonatomic, copy) NSString *contentString;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentWebViewHeightConstraint;
@property (nonatomic, copy) void(^finishBlock)();

@end
