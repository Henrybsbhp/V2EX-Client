//
//  V2MemberModel.h
//  V2EX · 读
//
//  Created by St.Jimmy on 12/15/15.
//  Copyright © 2015 Xing He. All rights reserved.
//

#import "V2BaseModel.h"

@interface V2MemberModel : V2BaseModel

@property (nonatomic, copy) NSString *memberId;
@property (nonatomic, copy) NSString *memberName;
@property (nonatomic, copy) NSString *memberAvatarMini;
@property (nonatomic, copy) NSString *memberAvatarNormal;
@property (nonatomic, copy) NSString *memberAvatarLarge;
@property (nonatomic, copy) NSString *memberTagline;

@property (nonatomic, copy) NSString *memberBio;
@property (nonatomic, copy) NSString *memberCreated;
@property (nonatomic, copy) NSString *memberLocation;
@property (nonatomic, copy) NSString *memberStatus;
@property (nonatomic, copy) NSString *memberTwitter;
@property (nonatomic, copy) NSString *memberUrl;
@property (nonatomic, copy) NSString *memberWebsite;

@end
