//
//  BPMultiRecordPromise.m
//  Blueprint
//
//  Created by Hunter on 5/1/16.
//  Copyright © 2016 Blueprint Project. All rights reserved.
//

#import "BPMultiRecordPromise.h"
#import "BPSubscriptionManager.h"
#import "BPQuery.h"
#import "BPCache.h"
#import "BPModel.h"

@interface BPMultiRecordPromise()
@property (strong) NSMutableArray<BPMultiRecordSuccessBlock>* successBlocks;
@property (strong) NSMutableArray<BPMultiRecordFailBlock>* failBlocks;

@property BOOL completed;

@property (strong) NSArray<BPRecord *> *records;
@property (strong) NSError *error;

@property (strong) NSString *subscription_key;

@property BOOL committed;
@property BOOL cached;

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
            [self commit];
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
            [self commit];
        }
    }
    
    return self;
}

-(void)commit
{
    if(!_committed){
        _committed = YES;
        
        BPMultiRecordPromise *cachedPromise = [BPCache checkCache:(BPQuery *)self.query];
        
        if(_cached || cachedPromise == nil) {
            [(BPQuery *)self.query execute];
        } else {
            [cachedPromise then:^(NSArray<BPRecord *> * _Nonnull records) {
                @synchronized (self) {
                    if(!_completed) {
                        _completed = YES;
                        
                        _records = records;

                        for(BPMultiRecordSuccessBlock block in _successBlocks) {
                            block(_records);
                        }
                    }
                }
            }];
            
            [cachedPromise fail:^(NSError * _Nonnull error) {
                @synchronized (self) {
                    if(!_completed) {
                        _completed = YES;
                        
                        _error = error;
                        
                        for(BPMultiRecordFailBlock block in _failBlocks) {
                            block(_error);
                        }
                    }
                }
            }];
        }
    }
}

-(BPMultiRecordPromise *)limit:(int)limit
{
    [(BPQuery *)self.query setQueryKey:@"$limit" to:@(limit)];
    return self;
}

-(BPMultiRecordPromise *)skip:(int)skip
{
    [(BPQuery *)self.query setQueryKey:@"$skip" to:@(skip)];
    return self;
}

-(BPMultiRecordPromise *)page:(int)page per:(int)per
{
    [self limit: per];
    [self skip: page * per];

    return self;
}


-(BPMultiRecordPromise *)sort:(NSDictionary<NSString*, id> *)sort
{
    [(BPQuery *)self.query setQueryKey:@"$sort" to:sort];
    return self;
}

-(BPMultiRecordPromise *)cache:(int)seconds
{
    if([BPCache checkCache:(BPQuery *)self.query] == nil) {
        [BPCache setPromise:self forQuery:(BPQuery *)self.query withExpirationTime:seconds];
        self.cached = YES;
    }
    
    return self;
}

#pragma mark - Subscriptions
-(BPMultiRecordPromise *)subscribeWithKey:(NSString *)key
{
    _subscription_key = key;
    return self;
}

-(BPMultiRecordPromise *)on:(BPMultiRecordEventBlock)block
{
    [BPSubscriptionManager subscribeToKey:self.subscription_key
                                forEndpoint:self.endpoint
                                   andEvent:@"all"
                                  withBlock:^(NSDictionary *data) {
                                      [self updateFromSubscriptionData:data];
                                      block(@"all", self.records);
                                  }];
    return self;
}

-(BPMultiRecordPromise *)onCreate:(BPMultiRecordSuccessBlock)block
{
    [BPSubscriptionManager subscribeToKey:self.subscription_key
                                forEndpoint:self.endpoint
                                   andEvent:@"create"
                                  withBlock:^(NSDictionary *data) {
        [self updateFromSubscriptionData:data];
        block(self.records);
    }];
    return self;
}

-(BPMultiRecordPromise *)onUpdate:(BPMultiRecordSuccessBlock)block
{
    [BPSubscriptionManager subscribeToKey:self.subscription_key
                                forEndpoint:self.endpoint
                                   andEvent:@"update"
                                withBlock:^(NSDictionary *data) {
                                    [self updateFromSubscriptionData:data];
                                    block(self.records);
    }];
    
    return self;
}

-(BPMultiRecordPromise *)onDestroy:(BPMultiRecordSuccessBlock)block
{
    [BPSubscriptionManager subscribeToKey:self.subscription_key
                                forEndpoint:self.endpoint
                                   andEvent:@"destroy"
                                withBlock:^(NSDictionary *data) {
                                    [self updateFromSubscriptionData:data];
                                    block(self.records);
    }];
    
    return self;
}

-(BOOL)updateFromSubscriptionData:(NSDictionary *)data
{
    NSArray *records = data[self.endpoint];
    NSMutableArray *local_records_copy = self.records.mutableCopy;
    
    BOOL ok = false;
    
    if(records) {
        for(NSDictionary *content in records) {
            ok = true;
            
            BOOL create = true;
            
            for(BPRecord *record in self.records) {
                if([[record objectId] isEqualToString:content[@"id"]]) {
                    [record updateWithData:content];
                    create = false;
                    break;
                }
            }
            
            if(create) {
                ok = true;
                
                BPRecord *record = [self.modelClass new];
                record.endpoint_name = self.endpoint;
                [record updateWithData:content];
                
                [local_records_copy addObject:record];
            }
        }
    }

    if(ok) {
        self.records = local_records_copy;
    }
    
    return ok;
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
