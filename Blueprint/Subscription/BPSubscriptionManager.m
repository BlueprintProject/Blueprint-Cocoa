//
//  BPSubscriptionManager.m
//  Blueprint
//
//  Created by Hunter on 5/13/16.
//  Copyright © 2016 Blueprint Project. All rights reserved.
//

#import "BPSubscriptionManager.h"
#import "BPApi.h"

@interface BPSubscriptionManager()

@property (strong) NSMutableDictionary *subscription_blocks;
@property (strong) NSMutableDictionary *subscription_key_map;

@end

@implementation BPSubscriptionManager

static BPSubscriptionManager *sharedManagerObject;

+(void)subscribeToQuery:(NSDictionary *)query
            forEndpoint:(NSString *)endpoint
               andEvent:(NSString *)event
              withBlock:(BPSubscriptionManagerQueryResponseBlock)block
{
    NSDictionary *subscription = @{
        @"event": event,
        @"query": query,
        @"endpoint": endpoint
    };
    
    [[BPSubscriptionManager sharedManager] registerSubscriptionWithDictionary:subscription
                                                                     andBlock:block];
}

+(void)subscribeToRecord:(BPRecord *)record
                forEvent:(NSString *)event
               withBlock:(BPSubscriptionManagerRecordResponseBlock)block
{
    NSDictionary *subscription = @{
       @"event": event,
       @"id": record.objectId,
       @"endpoint": record.endpoint_name
    };
    
    [[BPSubscriptionManager sharedManager] registerSubscriptionWithDictionary:subscription
                                                                     andBlock:block];
}

+(BPSubscriptionManager *)sharedManager
{
    if(sharedManagerObject == nil) {
        sharedManagerObject = [BPSubscriptionManager new];
        
        sharedManagerObject.subscription_blocks = @{}.mutableCopy;
        sharedManagerObject.subscription_key_map = @{}.mutableCopy;
    }
    
    return sharedManagerObject;
}

-(void)registerSubscriptionWithDictionary:(NSDictionary *)dictionary
                                 andBlock:(id)block
{
    NSString *key = [NSString stringWithFormat:@"%@%@%@",
                     dictionary[@"event"],
                     dictionary[@"endpoint"],
                     dictionary[@"id"] ? dictionary[@"id"] : dictionary[@"query"]];

    NSString *guid;
    
    @synchronized (_subscription_key_map) {
        guid = _subscription_key_map[key];
    }
    
    if(guid) {
        @synchronized (_subscription_blocks) {
            [_subscription_blocks[guid] addObject:block];
        }
    } else {
        guid = [[NSUUID UUID] UUIDString];
        @synchronized (_subscription_key_map) {
            _subscription_key_map[key] = guid;
        }
        
        @synchronized (_subscription_blocks) {
            _subscription_blocks[guid] = @[block].mutableCopy;
        }
        
        [self sendSubscriptionRequestWithDictionary:dictionary andGUID:guid];
    }
}

-(void)sendSubscriptionRequestWithDictionary:(NSDictionary *)dictionary
                                     andGUID:(NSString *)guid
{
    NSString *path;
    
    if(dictionary[@"id"]) {
        path = [NSString stringWithFormat:@"%@/%@/subscribe", dictionary[@"endpoint"], dictionary[@"id"]];
    } else {
        path = [NSString stringWithFormat:@"%@/subscribe", dictionary[@"endpoint"]];
    }
    
    [BPApi post:path withData:dictionary andBlock:^(NSError *error, id responseObject) {

    }];
}

@end
