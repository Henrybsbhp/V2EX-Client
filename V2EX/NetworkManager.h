//
//  NetworkManager.h
//  V2EX · 读
//
//  Created by St.Jimmy on 12/12/15.
//  Copyright © 2015 Xing He. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "V2UserModel.h"
#import "V2MemberModel.h"

typedef NS_ENUM(NSInteger, V2ErrorType) {
    
    V2ErrorTypeNoOnceAndNext          = 700,
    V2ErrorTypeLoginFailure           = 701,
    V2ErrorTypeRequestFailure         = 702,
    V2ErrorTypeGetFeedURLFailure      = 703,
    V2ErrorTypeGetTopicListFailure    = 704,
    V2ErrorTypeGetNotificationFailure = 705,
    V2ErrorTypeGetFavUrlFailure       = 706,
    V2ErrorTypeGetMemberReplyFailure  = 707,
    V2ErrorTypeGetTopicTokenFailure   = 708,
    V2ErrorTypeGetCheckInURLFailure   = 709,
    
};

@interface NetworkManager : NSObject

@property (nonatomic, strong) V2UserModel *user;

+ (instancetype)manager;

- (NSURLSessionDataTask *)requestOnceWithURLString:(NSString *)urlString success:(void (^)(NSString *onceString))success
                                           failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)loginWithUsername:(NSString *)username password:(NSString *)password
                                    success:(void (^)(NSString *message))success
                                    failure:(void (^)(NSError *error))failure;

- (NSString *)findOnceInHTMLString:(NSString *)HTMLString;

- (NSURLSessionDataTask *)getMemberProfileWithUserId:(NSString *)userid
                                            username:(NSString *)username
                                             success:(void (^)(V2MemberModel *member))success
                                             failure:(void (^)(NSError *error))failure;

@end
