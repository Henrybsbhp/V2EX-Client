//
//  contenHeaderView.m
//  V2EX
//
//  Created by St.Jimmy on 6/28/15.
//  Copyright (c) 2015 Xing He. All rights reserved.
//

#import "contenHeaderView.h"

@implementation contenHeaderView


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

- (void)setContentString:(NSString *)contentString
{
    _contentString = [contentString copy];
    
    [self.contentWebView loadHTMLString:[NSString stringWithFormat:
                                         @"<html> \n"
                                         "<head> \n"
                                         "<style type=\"text/css\"> \n"
                                         "body {font-family: \"helvetica\"; line-height: 22px; font-size: 16; color: #4a4a4a; margin: 0;}\n"
                                         "</style> \n"
                                         "</head> \n"
                                         "<body>%@</body> \n"
                                         "</html>", _contentString] baseURL:nil];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.contentWebView.hidden = NO;
    [self setNeedsLayout];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
