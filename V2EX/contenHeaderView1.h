//
//  contenHeaderView.h
//  V2EX
//
//  Created by St.Jimmy on 6/28/15.
//  Copyright (c) 2015 Xing He. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContenHeaderView : UIView <UIWebViewDelegate, UITextViewDelegate>

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, weak) IBOutlet UILabel *nodeLabel;
@property (nonatomic, weak) IBOutlet UILabel *lzIDLabel;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *numOfRepLabel;
@property (nonatomic, weak) IBOutlet UILabel *byLabel;
@property (nonatomic, weak) IBOutlet UIView *borderView;
@property (nonatomic, weak) IBOutlet UIView *contentSepView;

@property (nonatomic, copy) NSString *contentString;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentWebViewHeightConstraint;
@property (nonatomic, copy) void(^finishBlock)();

@end
