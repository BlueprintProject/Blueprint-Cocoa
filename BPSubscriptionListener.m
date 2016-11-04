//
//  BPSubscriptionListener.m
//  Blueprint
//
//  Created by Hunter on 5/14/16.
//  Copyright © 2016 Blueprint Project. All rights reserved.
//

#import "BPSubscriptionListener.h"
#import "BPApi.h"
#import "BPSubscriptionManager.h"

@interface BPSubscriptionListener()
@property (strong) NSTimer *listenLoopTimer;
@property (strong) NSString *guid;
@property BOOL longPollRequestDeferredToTimer;

@end

@implementation BPSubscriptionListener

-(id)initWithGuid:(NSString *)guid
{
    self = [super init];
    
    if(self) {
        self.guid = guid;
        [self run];
    }
    
    return self;
}

-(void)run
{
    [self resetListenLoopTimer];
    _longPollRequestDeferredToTimer = NO;
    
    NSMutableDictionary *poll_request = @{
      @"guid": self.guid,
      @"subscriptions": [BPSubscriptionManager subscriptions]
    }.mutableCopy;
    
    [BPApi post:@"/poll" withData:poll_request authenticated:YES andBlock:^(NSError *error, id responseObject) {
        if(error) {
            _longPollRequestDeferredToTimer = YES;
        } else {
            [self handleLongPollResult: responseObject];
            [self run];
        }
    }];
    
}

-(void)handleLongPollResult:(NSDictionary *)result
{
    NSDictionary *response = result[@"response"];
    if(response) {
        for(NSString *guid in response) {
            [BPSubscriptionManager handleData:response[guid] forGuid:guid];
        }
    }
}

#pragma mark - Listen Loop

-(void)resetListenLoopTimer
{
    if(_listenLoopTimer) {
        [_listenLoopTimer invalidate];
    }
    
    _listenLoopTimer = [NSTimer scheduledTimerWithTimeInterval:31
                                                        target:self
                                                      selector:@selector(listenLoopTimerCompleted)
                                                      userInfo:nil
                                                       repeats:YES];
}

-(void)listenLoopTimerCompleted
{
    if(_longPollRequestDeferredToTimer) {
        [self run];
    }
}

@end
