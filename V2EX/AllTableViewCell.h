//
//  AllTableViewCell.h
//  V2EX
//
//  Created by St.Jimmy on 5/14/15.
//  Copyright (c) 2015 Xing He. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AllTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *nodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *repliesLabel;

@property (weak, nonatomic) IBOutlet UIImageView *IDImageView;

@end
