//
//  SJBannerAlertView.m
//  V2EX · 读
//
//  Created by St.Jimmy on 4/10/16.
//  Copyright © 2016 Xing He. All rights reserved.
//

#import "SJBannerAlertView.h"

@interface SJBannerAlertView() <UITableViewDelegate>

@property (nonatomic, retain) UIView *view;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) UIColor *backgroundColor;
@property (nonatomic, assign) CGFloat alpha;

@property (nonatomic, retain) UIViewController *targetVC;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UIView *bannerView;
@property (nonatomic, retain) UILabel *bannerLabel;

@end

@implementation SJBannerAlertView

+ (instancetype)sharedView {
    static SJBannerAlertView *alertView;
    alertView = [[SJBannerAlertView alloc] init];
    
    return alertView;
}

+ (UIView *)showBannerAlertViewWithMessage:(NSString *)alertMessage backgroundColor:(UIColor *)color alpha:(CGFloat)alpha onTargetView:(UIView *)targetView withViewController:(UIViewController *)vc
{
    return [[self sharedView] bannerAlertViewWithMessage:alertMessage backgroundColor:color alpha:alpha onTargetView:targetView withViewController:vc];
}

- (UIView *)bannerAlertViewWithMessage:(NSString *)alertMessage backgroundColor:(UIColor *)color alpha:(CGFloat)alpha onTargetView:(UIView *)targetView withViewController:(UIViewController *)vc
{

    self.message = alertMessage;
    self.backgroundColor = color;
    self.alpha = alpha;
    self.view = targetView;
    self.targetVC = vc;
    
    return [self showBannerAlertView];
    
}

- (UIView *)showBannerAlertView
{
    // Create a view to hold the label and add images or whatever, place it off screen at -100
    UIView *alertView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 25)];
    alertView.backgroundColor = self.backgroundColor;
    alertView.alpha = self.alpha;
    
    // Create a label to display the message and add it to the alertView
    UILabel *theMessage = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(alertView.bounds), CGRectGetHeight(alertView.bounds))];
    theMessage.text = self.message;
    theMessage.font = [UIFont systemFontOfSize:12];
    theMessage.textColor = [UIColor whiteColor];
    theMessage.textAlignment = NSTextAlignmentCenter;
    [alertView addSubview:theMessage];
    
    UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
    
    [currentWindow addSubview:alertView];

    
//    // Add the alertView to the view
//    [self.targetVC.navigationController.navigationBar insertSubview:alertView belowSubview:self.targetVC.navigationController.navigationBar];
//    [self.targetVC.navigationController.navigationBar sendSubviewToBack:alertView];
    
    return alertView;
}

@end
