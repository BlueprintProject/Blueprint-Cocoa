//
//  BPSingleRecordPromise.m
//  Blueprint
//
//  Created by Hunter on 5/1/16.
//  Copyright © 2016 Blueprint Project. All rights reserved.
//

#import "BPSingleRecordPromise.h"
#import "BPQuery.h"
#import "BPRecord.h"

@interface BPSingleRecordPromise()
@property (strong) NSMutableArray<BPSingleRecordSuccessBlock>* successBlocks;
@property (strong) NSMutableArray<BPSingleRecordFailBlock>* failBlocks;

@property BOOL completed;

@property (strong) BPRecord *record;
@property (strong) NSError *error;

@property BOOL committed;

@property (strong) BPQuery *query;

@property (strong) NSString *endpoint;
@property (strong) Class modelClass;
@end

@implementation BPSingleRecordPromise

-(instancetype)init
{
    self = [super init];
    if(self) {
        self.successBlocks = [[NSMutableArray alloc] init];
        self.failBlocks = [[NSMutableArray alloc] init];
    }
    
    return self;
}

#pragma mark - Basic Promises

-(BPSingleRecordPromise *)then:(BPSingleRecordSuccessBlock)block
{
    @synchronized (self) {
        if(_completed) {
            if(_record) {
                block(_record);
            }
        } else {
            [_successBlocks addObject:block];
            [self commit];
        }
    }
    
    return self;
}

-(BPSingleRecordPromise *)fail:(BPSingleRecordFailBlock)block
{
    @synchronized (self) {
        if(_completed) {
            
            if(_error == nil) {
                _error = [NSError errorWithDomain:@"org.blueprint" code:1 userInfo:nil];
            }
            
            block(_error);
        } else {
            [_failBlocks addObject:block];
            [self commit];
        }
    }
    
    return self;
}

-(BPSingleRecordPromise *)cache:(int)seconds
{
    
    return self;
}

-(void)commit
{
    if(!_committed){
        _committed = YES;
        [self.query execute];
    }
}


#pragma mark - Subscriptions

-(BPSingleRecordPromise *)on:(BPSingleRecordEventBlock)block
{
    [self then:^(BPRecord * _Nonnull record) {
        [record on:block];
    }];
    
    return self;
}

-(BPSingleRecordPromise *)onUpdate:(BPSingleRecordSuccessBlock)block
{
    [self then:^(BPRecord * _Nonnull record) {
        [record onUpdate:block];
    }];
    
    return self;
}

-(BPSingleRecordPromise *)onDestroy:(BPSingleRecordSuccessBlock)block
{
    [self then:^(BPRecord * _Nonnull record) {
        [record onDestroy:block];
    }];
    
    return self;
}

#pragma mark - Private Methods

-(void)completeWith:(BPRecord * _Nullable)record andError:(NSError * _Nullable)error
{
    @synchronized (self) {
        if(!_completed) {
            _completed = YES;

            _record = record;
            _error = error;
            
            if(_error) {
                for(BPSingleRecordFailBlock block in _failBlocks) {
                    block(_error);
                }
            } else if(_record) {
                for(BPSingleRecordSuccessBlock block in _successBlocks) {
                    block(_record);
                }
            }
        }
    }
}

@end
