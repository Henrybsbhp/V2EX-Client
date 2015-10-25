//
//  repliesTableViewCell.h
//  V2EX
//
//  Created by St.Jimmy on 5/25/15.
//  Copyright (c) 2015 Xing He. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"

@interface RepliesTableViewCell : UITableViewCell <UITextViewDelegate, TTTAttributedLabelDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *repliesImageView;
@property (weak, nonatomic) IBOutlet UILabel *repliesID;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *repliesLabel;
@property (weak, nonatomic) IBOutlet UILabel *repliesTime;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewConstraintHeight;

@end
