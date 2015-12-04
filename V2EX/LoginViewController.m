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

typedef NS_ENUM(NSInteger, V2RequestMethod) {
    V2RequestMethodJSONGET    = 1,
    V2RequestMethodHTTPPOST   = 2,
    V2RequestMethodHTTPGET    = 3,
    V2RequestMethodHTTPGETPC  = 4
};

@interface LoginViewController ()

@property (nonatomic, strong) AFHTTPSessionManager *manager;

@property (nonatomic, copy) NSString *userAgentMobile;
@property (nonatomic, copy) NSString *userAgentPC;

@end

@implementation LoginViewController

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
    NSInteger success = 0;
    @try {
        
        if([[self.txtUsername text] isEqualToString:@""] || [[self.txtPassword text] isEqualToString:@""] ) {
            
            [self alertStatus:@"Please enter Email and Password" :@"Sign in Failed!" :0];
            
        } else {
            self.manager = [AFHTTPSessionManager manager];
            self.manager.requestSerializer = [AFJSONRequestSerializer serializer];
            self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            
            [self.manager GET:@"https://www.v2ex.com/signin" parameters:nil
                      success:^void(NSURLSessionDataTask * task, id responseObject) {
                          NSString *HTMLString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                          
                          NSString *once = [self findOnceInHTMLString:HTMLString];
                          NSLog(@"ONCE: %@", once);
                          
                          [self loginWithOnce:once username:self.txtUsername.text password:self.txtPassword.text];
                          
                      } failure:^void(NSURLSessionDataTask * operation, NSError * error) {
                          NSLog(@"Error: %@", error);
                      }];

            
            
           /* NSError *error = [[NSError alloc] init];
            NSHTTPURLResponse *response = nil;
            NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            
            NSLog(@"Response code: %ld", (long)[response statusCode]);
            
            if ([response statusCode] >= 200 && [response statusCode] < 300)
            {
                NSString *responseData = [[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
                NSLog(@"Response ==> %@", responseData);
                
                NSError *error = nil;
                NSDictionary *jsonData = [NSJSONSerialization
                                          JSONObjectWithData:urlData
                                          options:NSJSONReadingMutableContainers
                                          error:&error];
                
                success = [jsonData[@"success"] integerValue];
                NSLog(@"Success: %ld",(long)success);
                
                if(success == 1)
                {
                    NSLog(@"Login SUCCESS");
                } else {
                    
                    NSString *error_msg = (NSString *) jsonData[@"error_message"];
                    [self alertStatus:error_msg :@"Sign in Failed!" :0];
                }
                
            } else {
                //if (error) NSLog(@"Error: %@", error);
                [self alertStatus:@"Connection Failed" :@"Sign in Failed!" :0];
            }
            */
        }
    }
    @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
        [self alertStatus:@"Sign in Failed." :@"Error!" :0];
    }
    if (success) {
        [self performSegueWithIdentifier:@"login_success" sender:self];
    }
}

- (void)loginWithOnce:(NSString *)once username:(NSString *)username password:(NSString *)password
{
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    
    self.manager = [AFHTTPSessionManager manager];
    self.manager.requestSerializer = [AFJSONRequestSerializer serializer];
    self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSDictionary *parameters = @{
                                 @"once" : once,
                                 @"next" : @"/",
                                 @"p" : password,
                                 @"u" : username,
                                 };
    
    NSLog(@"PARAMETERS: %@", parameters);
    
    [self.manager.requestSerializer setValue:@"www.v2ex.com" forHTTPHeaderField:@"Host"];
    [self.manager.requestSerializer setValue:@"https://www.v2ex.com" forHTTPHeaderField:@"Origin"];
    [self.manager.requestSerializer setValue:@"https://www.v2ex.com/signin" forHTTPHeaderField:@"Referer"];
    [self.manager.requestSerializer setValue:@"1" forHTTPHeaderField:@"Upgrade-Insecure-Requests"];
    [self.manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [self.manager.requestSerializer setValue:@"zh-CN,zh;q=0.8,ja;q=0.6,zh-TW;q=0.4" forHTTPHeaderField:@"Accept-Language"];
    [self.manager.requestSerializer setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.116 Safari/537.36" forHTTPHeaderField:@"User-Agent"];
    
    [self requestWithMethod:V2RequestMethodHTTPPOST URLString:@"https://www.v2ex.com/signin" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSString *htmlString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSLog(@"RESPONSE HTMLSTRING: %@", htmlString);
        
    }failure:^(NSError *error) {
        
    }];
    
}

- (NSString *)findOnceInHTMLString:(NSString *)HTMLString
{
    NSRange range = [HTMLString rangeOfString:@"(?<=value=\")\\d{5}(?=\" name=\"once\")" options:NSRegularExpressionSearch];
    if (range.length > 0) {
        return [HTMLString substringWithRange:range];
    } else {
        return nil;
    }
}

- (NSURLSessionDataTask *)requestWithMethod:(V2RequestMethod)method
                                  URLString:(NSString *)URLString
                                 parameters:(NSDictionary *)parameters
                                    success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                    failure:(void (^)(NSError *error))failure  {
    // stateBar
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    // Handle Common Mission, Cache, Data Reading & etc.
    void (^responseHandleBlock)(NSURLSessionDataTask *task, id responseObject) = ^(NSURLSessionDataTask *task, id responseObject) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        // Any common handler for Response
        
        //        NSLog(@"URL:\n%@", [task.currentRequest URL].absoluteString);
        
        
        success(task, responseObject);
        
    };
    
    // Create HTTPSession
    NSURLSessionDataTask *task = nil;
    
    [self.manager.requestSerializer setValue:self.userAgentMobile forHTTPHeaderField:@"User-Agent"];
    
    if (method == V2RequestMethodJSONGET) {
        AFHTTPResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
        self.manager.responseSerializer = responseSerializer;
        task = [self.manager GET:URLString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            responseHandleBlock(task, responseObject);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"Error: \n%@", [error description]);
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            failure(error);
        }];
    }
    if (method == V2RequestMethodHTTPGET) {
        AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
        self.manager.responseSerializer = responseSerializer;
        task = [self.manager GET:URLString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            responseHandleBlock(task, responseObject);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            failure(error);
        }];
    }
    if (method == V2RequestMethodHTTPPOST) {
        AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
        self.manager.responseSerializer = responseSerializer;
        task = [self.manager POST:URLString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            responseHandleBlock(task, responseObject);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            failure(error);
        }];
    }
    if (method == V2RequestMethodHTTPGETPC) {
        AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
        self.manager.responseSerializer = responseSerializer;
        [self.manager.requestSerializer setValue:self.userAgentPC forHTTPHeaderField:@"User-Agent"];
        task = [self.manager GET:URLString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            responseHandleBlock(task, responseObject);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            failure(error);
        }];
    }
    
    return task;
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
