//
//  BPMultiRecordPromise.m
//  Blueprint
//
//  Created by Hunter on 5/1/16.
//  Copyright © 2016 Blueprint Project. All rights reserved.
//

#import "BPMultiRecordPromise.h"
#import "BPSubscriptionManager.h"

@interface BPMultiRecordPromise()
@property (strong) NSMutableArray<BPMultiRecordSuccessBlock>* successBlocks;
@property (strong) NSMutableArray<BPMultiRecordFailBlock>* failBlocks;

@property BOOL completed;

@property (strong) NSArray<BPRecord *> *records;
@property (strong) NSError *error;

@property (strong) NSDictionary *query;
@property (strong) NSString *endpoint;

@end

@implementation BPMultiRecordPromise

-(instancetype)init
{
    self = [super init];
    if(self) {
        self.successBlocks = [[NSMutableArray alloc] init];
        self.failBlocks = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(BPMultiRecordPromise *)then:(BPMultiRecordSuccessBlock)block
{
    @synchronized (self) {
        if(_completed) {
            if(_records) {
                block(_records);
            }
        } else {
            [_successBlocks addObject:block];
        }
    }
    
    return self;
}

-(BPMultiRecordPromise *)fail:(BPMultiRecordFailBlock)block
{
    @synchronized (self) {
        if(_completed) {
            if(_error) {
                block(_error);
            }
        } else {
            [_failBlocks addObject:block];
        }
    }
    
    return self;
}


#pragma mark - Subscriptions

-(BPMultiRecordPromise *)on:(BPMultiRecordEventBlock)block
{
    [BPSubscriptionManager subscribeToQuery:self.query
                                forEndpoint:self.endpoint
                                   andEvent:@"all"
                                  withBlock:block];
    return self;
}

-(BPMultiRecordPromise *)onCreate:(BPMultiRecordSuccessBlock)block
{
    [BPSubscriptionManager subscribeToQuery:self.query
                                forEndpoint:self.endpoint
                                   andEvent:@"create"
                                  withBlock:^(NSString *event, NSArray<BPRecord *> *records) {
        block(records);
    }];
    return self;
}

-(BPMultiRecordPromise *)onUpdate:(BPMultiRecordSuccessBlock)block
{
    [BPSubscriptionManager subscribeToQuery:self.query
                                forEndpoint:self.endpoint
                                   andEvent:@"update"
                                  withBlock:^(NSString *event, NSArray<BPRecord *> *records) {
        block(records);
    }];
    
    return self;
}

-(BPMultiRecordPromise *)onDestroy:(BPMultiRecordSuccessBlock)block
{
    [BPSubscriptionManager subscribeToQuery:self.query
                                forEndpoint:self.endpoint
                                   andEvent:@"destroy"
                                  withBlock:^(NSString *event, NSArray<BPRecord *> *records) {
        block(records);
    }];
    
    return self;
}

#pragma mark - Private Arguments

-(void)completeWith:(NSArray<BPRecord *> * _Nullable)records andError:(NSError * _Nullable)error
{
    @synchronized (self) {
        if(!_completed) {
            _completed = YES;
            
            _records = records;
            _error = error;
            
            if(_error) {
                for(BPMultiRecordFailBlock block in _failBlocks) {
                    block(_error);
                }
            } else if(_records) {
                for(BPMultiRecordSuccessBlock block in _successBlocks) {
                    block(_records);
                }
            }
        }
    }
}

@end