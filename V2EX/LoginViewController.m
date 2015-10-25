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
#import "AFHTTPRequestOperationManager.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:@"https://www.v2ex.com/signin" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *htmlString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"JSON: %@", htmlString);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
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
            NSString *signIn = [NSString stringWithFormat:@"https://www.v2ex.com/signin"];
            NSURL *signInURL = [NSURL URLWithString:signIn];
            
            NSData *signInHTMLData = [NSData dataWithContentsOfURL:signInURL options:NSDataReadingUncached error:nil];
            
            TFHpple *signInParser = [TFHpple hppleWithHTMLData:signInHTMLData];
            
            // Get the Once nodes
            NSString *onceXPathQueryString = @"//input[@name='once']";
            NSArray *onceNodes = [signInParser searchWithXPathQuery:onceXPathQueryString];
            NSLog(@"ONCENODES IS: %@", onceNodes);
            NSString *onceString;
            
            for (TFHppleElement *element in onceNodes) {
                onceString = [element objectForKey:@"value"];
                NSLog(@"ONCESTRING IS: %@", onceString);
            }
            
            // NSString *post =[[NSString alloc] initWithFormat:@"u=%@&p=%@&once=%@&next=/",[self.txtUsername text],[self.txtPassword text],onceString];
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            [manager.requestSerializer setValue:@"https://www.v2ex.com/signin" forHTTPHeaderField:@"Referer"];
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            NSDictionary *parameters = @{
                                         @"once":onceString,
                                         @"next":@"/",
                                         @"p":[self.txtPassword text],
                                         @"u":[self.txtUsername text],
                                         };
            NSLog(@"PARAMETERS: %@", parameters);
            [manager POST:@"https://www.v2ex.com/signin" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSString *htmlString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                NSLog(@"JSON: %@", htmlString);
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
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

- (void) alertStatus:(NSString *)msg :(NSString *)title :(int) tag
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
