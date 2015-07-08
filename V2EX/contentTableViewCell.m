//
//  contentTableViewCell.m
//  V2EX
//
//  Created by St.Jimmy on 5/24/15.
//  Copyright (c) 2015 Xing He. All rights reserved.
//

#import "contentTableViewCell.h"

@implementation contentTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.contentWebView.scrollView.scrollEnabled = NO;
    self.contentWebView.delegate = self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    NSString *contentHeight = [self.contentWebView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight"];
    CGFloat height = ceilf(contentHeight.floatValue);
    
    if (self.contentWebViewHeightConstraint.constant != height) {
        self.contentWebViewHeightConstraint.constant = height;
        
        [self layoutIfNeeded];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setContentString:(NSString *)contentString
{
    _contentString = [contentString copy];
    
    [self.contentWebView loadHTMLString:[NSString stringWithFormat:
                                         @"<html> \n"
                                         "<head> \n"
                                         "<style type=\"text/css\"> \n"
                                         "body {font-family: \"helvetica\"; line-height: 22px; font-size: 14; color: #4a4a4a; margin: 0;}\n"
                                         "</style> \n"
                                         "</head> \n"
                                         "<body>%@</body> \n"
                                         "</html>", _contentString] baseURL:nil];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.titleLabel.text = @"";
    self.avatarImageView.image = nil;
    self.nodeLabel.text = @"";
    self.lzIDLabel.text = @"";
    self.contentWebView.hidden = YES;
    self.timeLabel.text = @"";
    self.numOfRepLabel.text = @"";
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.contentWebView.hidden = NO;
    [self setNeedsLayout];
}

@end
