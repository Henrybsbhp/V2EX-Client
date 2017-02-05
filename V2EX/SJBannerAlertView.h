//
//  SJBannerAlertView.h
//  V2EX · 读
//
//  Created by St.Jimmy on 4/10/16.
//  Copyright © 2016 Xing He. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SJBannerAlertView : NSObject

+ (UIView *)showBannerAlertViewWithMessage:(NSString *)alertMessage backgroundColor:(UIColor *)color alpha:(CGFloat)alpha onTargetView:(UIView *)targetView withViewController:(UIViewController *)vc;

@end
