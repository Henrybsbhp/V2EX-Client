//
//  LoginViewController.m
//  V2EX · 读
//
//  Created by St.Jimmy on 9/20/15.
//  Copyright © 2015 Xing He. All rights reserved.
//

#import "LoginViewController.h"
#import "TFHpple.h"
#import "AFHTTPRequestOperation.h"
#import "AFHTTPSessionManager.h"
#import "AFHTTPRequestOperationManager.h"
#import "NetworkManager.h"


@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)dealloc
{
    NSLog(@"LoginViewController deallocated");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)signinClicked:(id)sender
{

        
    if([[self.txtUsername text] isEqualToString:@""] || [[self.txtPassword text] isEqualToString:@""] ) {
            
        [self alertStatus:@"请输入用户名和密码" :@"登录失败!" :0];
            
    } else {
        
        [[NetworkManager manager] loginWithUsername:self.txtUsername.text password:self.txtPassword.text success:^(NSString *message) {

            [[NetworkManager manager] getMemberProfileWithUserId:nil username:self.txtUsername.text success:^(V2MemberModel *member) {
                    
                V2UserModel *user = [[V2UserModel alloc] init];
                    
                user.member = member;
                user.name = member.memberName;
                    
                    
                [NetworkManager manager].user = user;
                    
                    
                    
                [self dismissViewControllerAnimated:YES completion:nil];
                    
            } failure:^(NSError *error) {
                    
                    
            }];
                
        } failure:^(NSError *error) {
                
            NSString *reasonString;
                
            if (error.code < 700) {
                reasonString = @"请检查网络状态";
            } else {
                reasonString = @"请检查用户名或密码";
            }
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"登录失败" message: reasonString delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil, nil];
                
            [alertView show];
                
        }];
            
    }

}

- (void)alertStatus:(NSString *)msg:(NSString *)title:(int)tag
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil, nil];
    alertView.tag = tag;
    [alertView show];
}

- (IBAction)cancelButton:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:nil];
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
