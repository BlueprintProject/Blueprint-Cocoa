//
//  SFUser.m
//  The Blueprint Project
//
//  Created by Waruna de Silva on 5/19/15.
//  Copyright (c) 2015 Waruna. All rights reserved.
//

#import "BPUser.h"
#import "BPApi.h"
#import "BPAuth.h"
#import "BPSession.h"
#import "BPPromise+PrivateHeaders.h"

@implementation BPUser

+(BPPromise *)authenticateWithEmail:(NSString *)email
                    password:(NSString *)password
{
    return [BPAuth authenticateWithEmail:email password:password];
}

+(BPPromise *)authenticateWithFacebookId:(NSString *)facebook_id
                    facebookToken:(NSString *)facebook_token
{
    return [BPAuth authenticateWithFacebookId:facebook_id facebookToken:facebook_token];
}

+(BPPromise *)authenticateWithUserId:(NSString *)user_id
                transferToken:(NSString *)transferToken
{
    return [BPAuth authenticateWithUserID:user_id transferToken:transferToken];
}

+(BPPromise *)logout
{
    BPPromise *promise = [BPPromise new];
    [BPSession destroySession];
    NSError *err = [NSError errorWithDomain:@"org.blueprint" code:1 userInfo:nil];
    [promise completeWithError:err];
    
    return promise;
}

+(BPPromise *)registerUserWithEmail:(NSString *)email
                    password:(NSString *)password
                     andName:(NSString *)name
{
    BPPromise *promise = [BPPromise new];
    
    NSDictionary *data = @{
                           @"user": @{
                                   @"email": email,
                                   @"password": password,
                                   @"name": name
                                   }
                           };
    [BPApi post:@"users" withData:data andBlock:^(NSError *error, id responseObject) {
        if(error == nil) {
            NSDictionary *data = (NSDictionary *)responseObject;
            NSDictionary *user = data[@"response"][@"users"][0];
            
            [[BPSession sharedSession] setSession:@{
                                                    @"auth_token": user[@"auth_token"],
                                                    @"user_id": user[@"id"],
                                                    @"session_id": user[@"session_id"]
                                                    }];
            
        }

        [promise completeWithError:error];
    }];
    
    return promise;
}

+(BPPromise *)registerWithFacebookId:(NSString *)facebook_id
                facebookToken:(NSString *)facebook_token
                        email:(NSString *)email
                         name:(NSString *)name
{
    BPPromise *promise = [BPPromise new];
    
    NSDictionary *data = @{
                           @"user": @{
                                   @"facebook_id": facebook_id,
                                   @"facebook_token": facebook_token,
                                   @"name": name,
                                   @"email": email
                                   }
                           };
    [BPApi post:@"users" withData:data andBlock:^(NSError *error, id responseObject) {
        if(error == nil) {
            NSDictionary *data = (NSDictionary *)responseObject;
            NSDictionary *user = data[@"response"][@"users"][0];
            
            [[BPSession sharedSession] setSession:@{
                                                    @"auth_token": user[@"auth_token"],
                                                    @"user_id": user[@"id"],
                                                    @"session_id": user[@"session_id"]
                                                    }];
            
        }
        
        [promise completeWithError:error];
    }];
    
    return promise;
}

-(BPPromise *)updateWithData:(NSDictionary *)data
{
    BPPromise *promise = [BPPromise new];
    
    NSString *url = [NSString stringWithFormat:@"users/%@", self.objectId];
    
    [BPApi put:url withData:@{@"user":data} andBlock:^(NSError *error, id responseObject) {
        [promise completeWithError:error];
    }];
    
    return promise;
}

-(BPPromise *)destroyUser
{
    BPPromise *promise = [BPPromise new];
    
    NSString *url = [NSString stringWithFormat:@"users/%@/destroy", self.objectId];
    
    [BPApi post:url withData:@{} andBlock:^(NSError *error, id responseObject) {
        [promise completeWithError:error];
    }];
    
    return promise;
}

@end
