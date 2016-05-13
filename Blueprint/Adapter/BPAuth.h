//
//  BPAuth.h
//  The Blueprint Project
//
//  Created by Hunter Dolan on 5/29/15.
//  Copyright (c) 2015 The Blueprint Project. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BPPromise.h"

@interface BPAuth : NSObject
+(NSMutableDictionary *)signRequest:(NSMutableDictionary *)request
                               path:(NSString *)path
                          andMethod:(NSString *)method;

+(BPPromise *)authenticateWithEmail:(NSString *)email
                    password:(NSString *)password;

+(BPPromise *)authenticateWithFacebookId:(NSString *)facebook_id
                    facebookToken:(NSString *)facebook_token;

+(BPPromise *)authenticateWithUserID:(NSString *)user_id
                transferToken:(NSString *)transfer_token;

@end
