//
//  NetworkManager.m
//  V2EX · 读
//
//  Created by St.Jimmy on 12/12/15.
//  Copyright © 2015 Xing He. All rights reserved.
//

#import "NetworkManager.h"
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

static NSString *const kUsername = @"username";
static NSString *const kUserid = @"userid";
static NSString *const kAvatarURL = @"avatarURL";
static NSString *const kUserIsLogin = @"userIsLogin";

@interface NetworkManager ()

@property (nonatomic, strong) AFHTTPSessionManager *manager;

@property (nonatomic, copy) NSString *userAgentMobile;
@property (nonatomic, copy) NSString *userAgentPC;

@end

@implementation NetworkManager

- (instancetype)init
{
    UIWebView *webView = [[UIWebView alloc]initWithFrame:CGRectZero];
    self.userAgentMobile = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    self.userAgentPC = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.75.14 (KHTML, like Gecko) Version/7.0.3 Safari/537.75.14";
    
    NSURL *baseUrl = [NSURL URLWithString:@"https://www.v2ex.com"];
    self.manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseUrl];
    AFHTTPRequestSerializer* serializer = [AFHTTPRequestSerializer serializer];
    self.manager.requestSerializer = serializer;
    
    BOOL isLogin = [[[NSUserDefaults standardUserDefaults] objectForKey:kUserIsLogin] boolValue];
    if (isLogin) {
        V2UserModel *user = [[V2UserModel alloc] init];
        user.login = YES;
        V2MemberModel *member = [[V2MemberModel alloc] init];
        user.member = member;
        user.member.memberName = [[NSUserDefaults standardUserDefaults] objectForKey:kUsername];
        user.member.memberId = [[NSUserDefaults standardUserDefaults] objectForKey:kUserid];
        user.member.memberAvatarLarge = [[NSUserDefaults standardUserDefaults] objectForKey:kAvatarURL];
        _user = user;
    }
    
    return self;
}

+ (instancetype)manager
{
    static NetworkManager *manager = nil;
    manager = [[NetworkManager alloc] init];
    
    return manager;
}

- (void)setUser:(V2UserModel *)user {
    _user = user;
    
    if (user) {
        self.user.login = YES;
        
        [[NSUserDefaults standardUserDefaults] setObject:user.member.memberName forKey:kUsername];
        [[NSUserDefaults standardUserDefaults] setObject:user.member.memberId forKey:kUserid];
        [[NSUserDefaults standardUserDefaults] setObject:user.member.memberAvatarLarge forKey:kAvatarURL];
        [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:kUserIsLogin];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUsername];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserid];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kAvatarURL];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserIsLogin];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    
}

- (NSURLSessionDataTask *)requestOnceWithURLString:(NSString *)urlString success:(void (^)(NSString *onceString))success
                                           failure:(void (^)(NSError *error))failure {
    
    return [self requestWithMethod:V2RequestMethodHTTPGET URLString:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSString *HTMLString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSString *onceString = [self findOnceInHTMLString:HTMLString];
        if (onceString) {
            success(onceString);
        } else {
            
        }
        
    } failure:^(NSError *error) {
        failure(error);
    }];
    
}

- (NSURLSessionDataTask *)loginWithUsername:(NSString *)username password:(NSString *)password
                                                success:(void (^)(NSString *message))success
                                                failure:(void (^)(NSError *error))failure {
    
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    

    
    [self requestOnceWithURLString:@"https://www.v2ex.com/signin" success:^(NSString *onceString) {
        
        NSDictionary *parameters = @{
                                     @"once" : onceString,
                                     @"next" : @"/",
                                     @"p" : password,
                                     @"u" : username,
                                     };
        
        NSLog(@"PARAMETERS: %@", parameters);
        
        [self.manager.requestSerializer setValue:@"https://www.v2ex.com/signin" forHTTPHeaderField:@"Referer"];
        
        [self requestWithMethod:V2RequestMethodHTTPPOST URLString:@"https://www.v2ex.com/signin" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            
            NSLog(@"REQUEST URL: %@", self.manager.baseURL);
            
            NSString *htmlString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            
            NSLog(@"RESPONSE HTMLSTRING: %@", htmlString);
            
            if ([htmlString rangeOfString:@"/notifications"].location != NSNotFound) {
                success(username);
            } else {
                NSLog(@"THE BASEURL IS: %@", self.manager.baseURL);
                
                NSError *error = [[NSError alloc] initWithDomain:self.manager.baseURL.absoluteString code:V2ErrorTypeLoginFailure userInfo:nil];
                
                failure(error);
            }
            
        }failure:^(NSError *error) {
            failure(error);
        }];
        
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return nil;
    
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

- (NSURLSessionDataTask *)getMemberProfileWithUserId:(NSString *)userid
                                            username:(NSString *)username
                                             success:(void (^)(V2MemberModel *member))success
                                             failure:(void (^)(NSError *error))failure {
    
    NSDictionary *parameters;
    if (userid) {
        parameters = @{
                       @"id": userid,
                       };
    }
    if (username) {
        parameters = @{
                       @"username": username,
                       };
    }
    
    return [self requestWithMethod:V2RequestMethodJSONGET URLString:@"/api/members/show.json" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        V2MemberModel *member = [[V2MemberModel alloc] initWithDictionary:responseObject];
        success(member);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
}

@end
