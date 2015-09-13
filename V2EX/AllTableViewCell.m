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
    
    self.IDImageView.layer.cornerRadius = 5.0;
    self.IDImageView.layer.masksToBounds = YES;
    
    // titleLabel settings
    self.nodeLabel.layer.cornerRadius = 2.0;
    self.nodeLabel.layer.masksToBounds = YES;
    self.nodeLabel.backgroundColor = [UIColor colorWithRed:0.67 green:0.67 blue:0.65 alpha:1];
    self.nodeLabel.textColor = [UIColor colorWithRed:0.94 green:0.93 blue:0.91 alpha:1];
    self.borderView.layer.cornerRadius = 2.0;
    self.borderView.layer.masksToBounds = YES;
    self.borderView.backgroundColor = [UIColor colorWithRed:0.67 green:0.67 blue:0.65 alpha:1];
    
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
