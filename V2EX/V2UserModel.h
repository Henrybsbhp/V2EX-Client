//
//  V2UserModel.h
//  V2EX · 读
//
//  Created by St.Jimmy on 12/15/15.
//  Copyright © 2015 Xing He. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "V2MemberModel.h"

@interface V2UserModel : NSObject

@property (nonatomic, strong) V2MemberModel *member;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, strong) NSURL *feedURL;

@property (nonatomic, assign, getter = isLogin) BOOL login;


@end
