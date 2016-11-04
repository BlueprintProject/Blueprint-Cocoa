//
//  BPQuery.m
//  Blueprint-Cocoa
//
//  Created by Waruna de Silva on 6/1/15.
//  Copyright (c) 2015 The Blueprint Project. All rights reserved.
//

#import "BPQuery.h"
#import "BPApi.h"

@interface BPQuery()

@property (strong) NSMutableDictionary *request;
@property (strong) NSString *path;
@property int retryCount;
@property bpquery_completion_block completionBlock;

@end

@implementation BPQuery

@synthesize endpoint = _endpoint;

- (instancetype)initWithEndpoint:(NSString *)name
{
    self = [super init];
    if (self) {
        
        _endpoint = name;
    }
    return self;
}

+ (BPQuery *)queryForEndpoint:(NSString *)name
{
    return [[BPQuery alloc] initWithEndpoint:name];
}

- (void)setQuery:(NSDictionary *)where withBlock:(void (^)(NSError *error, NSArray *objects))completionBlock
{
    [self setQuery:where withBlock:completionBlock andRetryCount:0];
}

- (void)setQuery:(NSDictionary *)where
            withBlock:(bpquery_completion_block)completionBlock
        andRetryCount:(int)retry_count
{
    _request = @{ @"where" : where.mutableCopy}.mutableCopy;
    _path = [NSString stringWithFormat:@"%@/query",self.endpoint];
    _completionBlock = completionBlock;
    _retryCount = retry_count;
}

-(void)setQueryKey:(NSString *)key to:(NSObject *)value
{
    if(_request == nil) {
        _request = @{@"where": @{}.mutableCopy}.mutableCopy;
    } else if(_request[@"where"] == nil) {
        _request[@"where"] = @{}.mutableCopy;
    }
    
    
    _request[@"where"][key] = value;
}

- (void)execute
{
    [BPApi post:_path withData:_request andBlock:^(NSError *error, id responseObject) {
        if(error) {
            if(_retryCount > 2) {
                _completionBlock(error, @[]);
            } else {
                _retryCount++;
                [self execute];
            }
        } else {
            NSArray *objects = responseObject[@"response"][_endpoint];
            if([objects isEqual:[NSNull null]]) {
                objects = @[];
            }
            
            _completionBlock(error, objects);
        }
    }];
}

- (NSString *)cacheKey
{
    NSLog(@"%@", self.request);
    
    NSData *json_data = [NSJSONSerialization dataWithJSONObject:self.request
                                                        options:0
                                                          error:nil];    
    
    NSString *json = [[NSString alloc] initWithData:json_data encoding:NSUTF8StringEncoding];
    return [NSString stringWithFormat:@"%@%@", json, self.path];
}

@end
