//
//  repliesTableViewCell.m
//  V2EX
//
//  Created by St.Jimmy on 5/25/15.
//  Copyright (c) 2015 Xing He. All rights reserved.
//

#import "RepliesTableViewCell.h"

@implementation RepliesTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.backgroundColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1];
    
    self.repliesImageView.layer.cornerRadius = 5.0;
    self.repliesImageView.layer.masksToBounds = YES;
    
    self.repliesLabel.backgroundColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1];
    // remove the link's underline and change its color
    self.repliesLabel.linkAttributes = @{
                                         [NSNumber numberWithInt:kCTUnderlineStyleNone] : (id)kCTUnderlineStyleAttributeName,
                                         NSForegroundColorAttributeName : [UIColor colorWithRed:0.19 green:0.48 blue:1 alpha:1]
                                         };
    self.repliesLabel.activeLinkAttributes = @{
                                               (NSString *)kCTUnderlineStyleAttributeName: [NSNumber numberWithBool:NO],
                                               NSForegroundColorAttributeName: [UIColor whiteColor],
                                               (NSString *)kTTTBackgroundFillColorAttributeName: [UIColor colorWithRed:0.28 green:0.8 blue:1 alpha:1],
                                               (NSString *)kTTTBackgroundCornerRadiusAttributeName:[NSNumber numberWithFloat:4.0f]
                                               };
    
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
