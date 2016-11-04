//
//  Blueprint.h
//  Blueprint-Cocoa
//
//  Created by Waruna de Silva on 5/30/15.
//  Copyright (c) 2015 The Blueprint Project. All rights reserved.
//

#import "BPGroup.h"
#import "BPProfile.h"
#import "BPError.h"
#import "BPModel.h"

@interface Blueprint : NSObject

+(void)setConfig:(NSDictionary *)config;

+(void)setProfileClass:(Class)klass;

#pragma mark - BPUser

+(BPPromise *)registerWithEmail:(NSString *)email
                password:(NSString *)password
                    name:(NSString *)name;

+(BPPromise *)registerWithFacebookId:(NSString *)facebook_id
                facebookToken:(NSString *)facebook_token
                        email:(NSString *)email
                         name:(NSString *)name;

+(BPPromise *)authenticateWithEmail:(NSString *)email
                    password:(NSString *)password;

+(BPPromise *)authenticateWithFacebookId:(NSString *)facebook_id
                    facebookToken:(NSString *)facebook_token;


+(BPPromise *)authenticateWithUserId:(NSString *)user_id
                transferToken:(NSString *)transferToken;


+(BPPromise *)destroyCurrentUser;

+(BPPromise *)updateUserPassword:(NSString *)password
                 currentPassword:(NSString *)current_password;

+(BPPromise *)updateUserEmail:(NSString *)email;

#pragma mark - BPGroup
+(BPGroup *)publicGroup;
+(BPGroup *)privateGroup;

#pragma mark - BPProfile
+(BPSingleRecordPromise *)getProfileForUserWithId:(NSString *)user_id;
+(BPSingleRecordPromise *)getCurrentUserProfile;
+(BPSingleRecordPromise *)reloadCurrentUserProfile;

+(BPProfile *)cachedProfile;

#pragma mark - BPSession
+(BOOL)restoreSession;
+(NSString *)currentUserId;
+(void)destroySession;

+(void)setErrorHandler:(errorBlock)block;

#pragma mark - Multiplexed Requests
+(void)enableMultiplexedRequestsWithIdleTime:(int)idle_time andMaxCollectionTime:(int)max_collection_time;
+(void)runMultiplexedRequests;
+(void)disableMultiplexedRequests;
@end
