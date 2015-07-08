//
//  AllTableViewCell.m
//  V2EX
//
//  Created by St.Jimmy on 5/14/15.
//  Copyright (c) 2015 Xing He. All rights reserved.
//

#import "AllTableViewCell.h"

@implementation AllTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
