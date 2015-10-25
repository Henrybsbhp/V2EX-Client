//
//  repliesTableViewCell.m
//  V2EX
//
//  Created by St.Jimmy on 5/25/15.
//  Copyright (c) 2015 Xing He. All rights reserved.
//

#import "repliesTableViewCell.h"

@implementation repliesTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.backgroundColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1];
    
    self.repliesImageView.layer.cornerRadius = 5.0;
    self.repliesImageView.layer.masksToBounds = YES;
    
    // UITextView lose margin/padding
    self.repliesTextView.textContainerInset = UIEdgeInsetsMake(0, -5, -0, -5);
    [self.repliesTextView setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.repliesTextView.backgroundColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1];
    
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
