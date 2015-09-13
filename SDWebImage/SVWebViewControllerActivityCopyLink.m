//
//  SVWebViewControllerActivitySafari.m
//
//  Created by Sam Vermette on 11 Nov, 2013.
//  Copyright 2013 Sam Vermette. All rights reserved.
//
//  https://github.com/samvermette/SVWebViewController


#import "SVWebViewControllerActivityCopyLink.h"

@implementation SVWebViewControllerActivityCopyLink

- (NSString *)activityTitle {
	return NSLocalizedStringFromTable(@"Copy Link", @"SVWebViewController", nil);
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
	for (id activityItem in activityItems) {
		if ([activityItem isKindOfClass:[NSURL class]] && [[UIApplication sharedApplication] canOpenURL:activityItem]) {
			return YES;
		}
	}
	return NO;
}

- (void)performActivity {
    NSString *copyLink = [NSString stringWithFormat:@"%@", self.URLToOpen];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = copyLink;
}

@end
