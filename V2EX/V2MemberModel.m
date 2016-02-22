//
//  V2MemberModel.m
//  V2EX · 读
//
//  Created by St.Jimmy on 12/15/15.
//  Copyright © 2015 Xing He. All rights reserved.
//

#import "V2MemberModel.h"

@implementation V2MemberModel

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        
        self.memberId            = [dict objectForKey:@"id"];
        self.memberName          = [dict objectForKey:@"username"];
        self.memberAvatarMini    = [dict objectForKey:@"avatar_mini"];
        self.memberAvatarNormal  = [dict objectForKey:@"avatar_normal"];
        self.memberAvatarLarge   = [dict objectForKey:@"avatar_large"];
        self.memberTagline = [dict objectForKey:@"tagline"];
        
        if ([self.memberAvatarMini hasPrefix:@"//"]) {
            self.memberAvatarMini = [@"https:" stringByAppendingString:self.memberAvatarMini];
        }
        
        if ([self.memberAvatarNormal hasPrefix:@"//"]) {
            self.memberAvatarNormal = [@"https:" stringByAppendingString:self.memberAvatarNormal];
        }
        
        if ([self.memberAvatarLarge hasPrefix:@"//"]) {
            self.memberAvatarLarge = [@"http:" stringByAppendingString:self.memberAvatarLarge];
        }
        
        self.memberBio = [dict objectForKey:@"bio"];
        self.memberCreated = [dict objectForKey:@"created"];
        self.memberLocation = [dict objectForKey:@"location"];
        self.memberStatus = [dict objectForKey:@"status"];
        self.memberTwitter = [dict objectForKey:@"twitter"];
        self.memberUrl = [dict objectForKey:@"url"];
        self.memberWebsite = [dict objectForKey:@"website"];
        
    }
    
    return self;
}

@end
