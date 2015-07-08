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
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.repliesImageView.image = nil;
    self.repliesID.text = @"";
    self.repliesTextView.attributedText = nil;
    self.repliesTime.text = @"";
}

@end
