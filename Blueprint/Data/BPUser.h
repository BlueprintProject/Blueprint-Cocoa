//
//  SFUser.h
//  The Blueprint Project
//
//  Created by Waruna de Silva on 5/19/15.
//  Copyright (c) 2015 Waruna. All rights reserved.
//

#import "BPObject.h"
#import "BPPromise.h"

@interface BPUser : BPObject

@property (nonatomic, copy, readonly) NSString *authenticationToken;
@property (nonatomic, copy, readonly) NSString *userId;
@property (nonatomic, copy, readonly) NSString *sessionId;


+(BPPromise *)authenticateWithEmail:(NSString *)email
                    password:(NSString *)password;

+(BPPromise *)authenticateWithFacebookId:(NSString *)facebook_id
                    facebookToken:(NSString *)facebook_token;

+(BPPromise *)authenticateWithUserId:(NSString *)user_id
                transferToken:(NSString *)transferToken;

+(BPPromise *)logout;

+(BPPromise *)registerUserWithEmail:(NSString *)email
                    password:(NSString *)password
                     andName:(NSString *)name;

+(BPPromise *)registerWithFacebookId:(NSString *)facebook_id
                facebookToken:(NSString *)facebook_token
                        email:(NSString *)email
                                name:(NSString *)name;

-(BPPromise *)destroyUser;

-(BPPromise *)updateWithData:(NSDictionary *)data;



@end
