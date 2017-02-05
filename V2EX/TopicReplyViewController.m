//
//  TopicReplyViewController.m
//  V2EX · 读
//
//  Created by St.Jimmy on 2/26/16.
//  Copyright © 2016 Xing He. All rights reserved.
//

#import "TopicReplyViewController.h"
#import "NetworkManager.h"
#import "SJBannerAlertView.h"
#import "LoginViewController.h"

@interface TopicReplyViewController () <NSLayoutManagerDelegate, UIAlertViewDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UINavigationBar *naviBar;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendButton;


@end

@implementation TopicReplyViewController
{
    IBOutlet NSLayoutConstraint *_textViewSpaceToBottomConstraint;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"TopicReplyVC deallocated");
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1];
    self.naviBar.barTintColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1];
    self.naviBar.tintColor = [UIColor colorWithRed:0.26 green:0.26 blue:0.25 alpha:1];
    self.contentTextView.backgroundColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1];
    
    [self.naviBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [self.naviBar setShadowImage:[[UIImage alloc] init]];
    
    self.contentTextView.layoutManager.delegate = self;
    self.contentTextView.textContainerInset = UIEdgeInsetsMake(15, 8, 15, 8);
    
    // Register notifications for when the keyboard appears
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    if (self.repUsrID) {
        self.contentTextView.text = self.repUsrID;
    }
    
    self.contentTextView.delegate = self;
    
    if (self.contentTextView.text.length != 0) {
        self.sendButton.enabled = YES;
    } else {
        self.sendButton.enabled = NO;
    }
    
    [self.contentTextView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.contentTextView resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey]CGRectValue];
    
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey]doubleValue];
    
    UIViewAnimationOptions options = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey]intValue];
    
    _textViewSpaceToBottomConstraint.constant = keyboardFrame.size.height;
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:options
                     animations:^{
                         
                         [self.view layoutIfNeeded];
                         
                     } completion:nil];

}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey]doubleValue];
    
    UIViewAnimationOptions options = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey]intValue];
    
    _textViewSpaceToBottomConstraint.constant = 0;
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:options
                     animations:^{
                         
                         [self.view layoutIfNeeded];
                         
                     } completion:nil];
    
}
- (void)textViewDidChange:(UITextView *)textView
{
    if (self.contentTextView.text.length != 0) {
        self.sendButton.enabled = YES;
    } else {
        self.sendButton.enabled = NO;
    }
}

- (IBAction)sendButtonClicked:(id)sender
{
    NSLog(@"REPLY URL IS: %@", self.urlString);
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
    [[NetworkManager manager] replyWithContent:self.contentTextView.text url:self.urlString success:^(NSString *message) {
        
        [self.contentTableViewController showBannerAlertViewWithView:[SJBannerAlertView showBannerAlertViewWithMessage:@"回复成功！" backgroundColor:[UIColor colorWithRed:0.22 green:0.47 blue:0.92 alpha:1.00] alpha:0.9f onTargetView:self.topicView withViewController:self.contentTableViewController]];
        
    } failure:^(NSError *error) {
        
        NSString *reasonString;
        
        if (error.code < 700) {
            reasonString = @"请检查网络状态";
        } else {
            reasonString = @"抱歉，登录信息已失效或者您尚未登录，请重新登录";
        }
        
        if ([reasonString isEqualToString:@"请检查网络状态"]) {
            
            [self.contentTableViewController showBannerAlertViewWithView:[SJBannerAlertView showBannerAlertViewWithMessage:@"回复失败，请检查网络状态" backgroundColor:[UIColor redColor] alpha:0.9f onTargetView:self.topicView withViewController:self.contentTableViewController]];
            
            return;
        }
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"回复失败" message:reasonString delegate:self.contentTableViewController cancelButtonTitle:@"确定" otherButtonTitles: nil, nil];
        
        [alertView show];
    }];
}

- (IBAction)cancelButtonClicked:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - LayoutManager Delegate
- (CGFloat)layoutManager:(NSLayoutManager *)layoutManager lineSpacingAfterGlyphAtIndex:(NSUInteger)glyphIndex withProposedLineFragmentRect:(CGRect)rect
{
    return 4; // Line spacing of 19 is roughly equivalent to 5 here.
}

#pragma mark - AlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [self presentViewController:loginVC animated:YES completion:nil];
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
