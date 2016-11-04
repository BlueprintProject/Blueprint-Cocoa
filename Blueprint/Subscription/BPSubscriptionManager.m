//
//  BPSubscriptionManager.m
//  Blueprint
//
//  Created by Hunter on 5/13/16.
//  Copyright © 2016 Blueprint Project. All rights reserved.
//

#import "BPSubscriptionManager.h"
#import "BPApi.h"
#import "BPSubscriptionListener.h"

@interface BPSubscriptionManager()

@property (strong) NSMutableDictionary *subscription_blocks;
@property (strong) NSMutableDictionary *subscription_key_map;

@property (strong) NSMutableDictionary *subscription_map;

@property (strong) NSString *guid;

@property (strong) BPSubscriptionListener *listener;


@end

@implementation BPSubscriptionManager

static BPSubscriptionManager *sharedManagerObject;

+(void)subscribeToKey:(NSString *)key
            forEndpoint:(NSString *)endpoint
               andEvent:(NSString *)event
              withBlock:(BPSubscriptionManagerQueryResponseBlock)block
{
    NSDictionary *subscription = @{
        @"event": event,
        @"key": key,
        @"guid": [[NSUUID UUID] UUIDString],
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
       @"guid": [[NSUUID UUID] UUIDString],
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
        
        sharedManagerObject.subscription_map = @{}.mutableCopy;
        
        sharedManagerObject.guid = [[NSUUID UUID] UUIDString];
    }
    
    return sharedManagerObject;
}

-(void)registerSubscriptionWithDictionary:(NSDictionary *)dictionary
                                 andBlock:(id)block
{
    self.subscription_map[dictionary[@"guid"]] = dictionary;
    
    if(self.listener == nil) {
        self.listener = [[BPSubscriptionListener alloc]  initWithGuid:_guid];
    }
    
    NSString *key = [NSString stringWithFormat:@"%@%@%@",
                     dictionary[@"event"],
                     dictionary[@"endpoint"],
                     dictionary[@"id"] ? dictionary[@"id"] : dictionary[@"key"]];

    NSString *guid;
    
    @synchronized (_subscription_key_map) {
        guid = _subscription_key_map[key];
    }
    
    if(guid) {
        @synchronized (_subscription_blocks) {
            [_subscription_blocks[guid] addObject:block];
        }
    } else {
        guid = dictionary[@"guid"];
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
    
    [BPApi post:path withData:@{@"guid": guid, @"subscription": dictionary} andBlock:^(NSError *error, id responseObject) {

    }];
}

+(NSArray *)subscriptions
{
    return [BPSubscriptionManager sharedManager].subscription_map.allValues;
}

+(void)handleData:(NSDictionary *)data forGuid:(NSString *)guid;
{
    [[BPSubscriptionManager sharedManager] handleData:data forGuid:guid];
}

-(void)handleData:(NSDictionary *)data forGuid:(NSString *)guid
{
    NSArray *blocks = _subscription_blocks[blocks];
    
    for(BPSubscriptionManagerRecordResponseBlock block in blocks) {
        block(data);
    }
}

@end
