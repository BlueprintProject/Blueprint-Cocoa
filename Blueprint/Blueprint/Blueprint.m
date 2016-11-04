//
//  Blueprint.m
//  The Blueprint Project
//
//  Created by Hunter Dolan on 5/29/15.
//  Copyright (c) 2015 The Blueprint Project. All rights reserved.
//

#import "Blueprint.h"
#import "BPUser.h"
#import "BPConfig.h"
#import "BPSession.h"
#import "BPApi.h"

#import "BPPromise.h"
#import "BPPromise+PrivateHeaders.h"

@implementation Blueprint

static BPProfile *cachedProfile;
static Class profileClass;

static NSMutableArray *profileLoadObservers;

static bool loadingProfile;

#pragma mark - BPConfig

+(void)setConfig:(NSDictionary *)config
{
    [BPConfig setConfig:config];
}

+(void)setProfileClass:(Class)klass
{
    profileClass = klass;
}

+(Class)profileClass
{
    if(profileClass == nil) {
        return [BPProfile class];
    } else {
        return profileClass;
    }
}

#pragma mark - BPUser

+(BPPromise *)registerWithEmail:(NSString *)email
                password:(NSString *)password
                    name:(NSString *)name
{
    BPPromise *promise;
    
    if([Blueprint currentUserId]) {
        promise = [BPPromise new];
        NSError *err = [NSError errorWithDomain:@"org.blueprint" code:1 userInfo:nil];
        [promise completeWithError:err];
    } else {
        promise = [BPUser registerUserWithEmail:email password:password andName:name];
    }
    
    return promise;
}

+(BPPromise *)registerWithFacebookId:(NSString *)facebook_id
                facebookToken:(NSString *)facebook_token
                        email:(NSString *)email
                         name:(NSString *)name
{
    BPPromise *promise;

    if([Blueprint currentUserId]) {
        promise = [BPPromise new];
        NSError *err = [NSError errorWithDomain:@"org.blueprint" code:1 userInfo:nil];
        [promise completeWithError:err];
    } else {
        return [BPUser registerWithFacebookId:facebook_id
                                facebookToken:facebook_token
                                        email:email
                                         name:name];
    }
    
    return promise;
}

+(BPPromise *)authenticateWithEmail:(NSString *)email
                    password:(NSString *)password
{
    return [BPUser authenticateWithEmail:email password:password];
}

+(BPPromise *)authenticateWithFacebookId:(NSString *)facebook_id
                   facebookToken:(NSString *)facebook_token
{
    return [BPUser authenticateWithFacebookId:facebook_id facebookToken:facebook_token];
}


+(BPPromise *)authenticateWithUserId:(NSString *)user_id
                transferToken:(NSString *)transferToken
{
    return [BPUser authenticateWithUserId:user_id
                     transferToken:transferToken];
}

+(BPPromise *)destroyCurrentUser
{
    BPUser *user = [BPUser new];
    user.objectId = [Blueprint currentUserId];
    BPPromise *promise = [user destroyUser];
    
    [promise then:^{
        [self destroySession];
    }];
    
    return promise;
}

+(BPPromise *)updateUserEmail:(NSString *)email
{
    BPUser *user = [BPUser new];
    user.objectId = [Blueprint currentUserId];
    
    return [user updateWithData:@{@"email":email}];
}

+(BPPromise *)updateUserPassword:(NSString *)password currentPassword:(NSString *)current_password
{
    BPUser *user = [BPUser new];
    user.objectId = [Blueprint currentUserId];
    
    return [user updateWithData:@{@"password":password, @"current_password": current_password}];
}


#pragma mark - BPSession

+(BOOL)restoreSession
{
    return [BPSession restoreSession];
}

+(NSString *)currentUserId
{
    return [BPSession user_id];
}

+(void)destroySession
{
    cachedProfile = nil;
    loadingProfile = NO;
    [BPSession destroySession];
}

#pragma mark - BPProfile
+(BPSingleRecordPromise *)getProfileForUserWithId:(NSString *)user_id
{
    return [[Blueprint profileClass] getProfileForUserWithId:user_id];
}

+(BPSingleRecordPromise *)getCurrentUserProfile
{
    BPSingleRecordPromise *promise = [BPSingleRecordPromise new];

    if(cachedProfile) {
        [promise completeWith:cachedProfile andError:nil];
    } else if(loadingProfile) {
        if(profileLoadObservers == nil) {
            profileLoadObservers = @[].mutableCopy;
        }
        @synchronized(profileLoadObservers) {
            [profileLoadObservers addObject:promise];
        }
    } else {
        return [Blueprint reloadCurrentUserProfile];
    }
    
    return promise;
}

+(BPSingleRecordPromise *)reloadCurrentUserProfile
{
    BPSingleRecordPromise *promise;

    if([self currentUserId]) {
        loadingProfile = YES;
        promise = [[Blueprint profileClass] getProfileForUserWithId:[self currentUserId]];
        
        [promise then:^(BPRecord * _Nonnull record) {
            loadingProfile = NO;

            BPProfile *profile = (BPProfile *)record;
            
            cachedProfile = profile;
            
            [self notifyOfProfileUpdateWithError:nil];
        }];
        
        [promise fail:^(NSError * _Nonnull error) {
            loadingProfile = NO;

            BPProfile *profile = [[Blueprint profileClass] new];
            [profile addReadGroup:[Blueprint publicGroup]];
            [profile addReadGroup:[Blueprint privateGroup]];
            [profile addDestroyGroup:[Blueprint privateGroup]];
            [profile addWriteGroup:[Blueprint privateGroup]];
            
            cachedProfile = profile;
            [self notifyOfProfileUpdateWithError:error];
        }];
    } else {
        promise = [BPSingleRecordPromise new];
        [promise completeWith:nil andError:nil];
    }
    
    return promise;
}

+(void)notifyOfProfileUpdateWithError:(NSError *)error
{
    if(profileLoadObservers) {
        @synchronized(profileLoadObservers) {
            for(BPSingleRecordPromise *promise in profileLoadObservers) {
                [promise completeWith:cachedProfile andError:error];
            }
            
            profileLoadObservers = @[].mutableCopy;
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BPUpdateProfile" object:nil];
}

+(BPProfile *)cachedProfile
{
    return cachedProfile;
}

#pragma mark - BPGroup

+(BPGroup *)publicGroup
{
    return [BPGroup groupWithId:[BPConfig public_group_id]];
}

+(BPGroup *)privateGroup
{
    return [BPGroup groupWithId:[BPSession user_id]];
}

#pragma mark - Handle Error
+(void)setErrorHandler:(errorBlock)block
{
    [BPError setErrorHandler:block];
}

#pragma mark - Multiplexed Requests
+(void)enableMultiplexedRequestsWithIdleTime:(int)idle_time andMaxCollectionTime:(int)max_collection_time
{
    [BPApi enableMultiplexedRequestsWithIdleTime:idle_time andMaxCollectionTime:max_collection_time];
}

+(void)runMultiplexedRequests
{
    [BPApi runMultiplexedRequests];
}

+(void)disableMultiplexedRequests
{
    [BPApi disableMultiplexedRequests];
}


@end
