//
//  BPApi.m
//  The Blueprint Project
//
//  Created by Hunter Dolan on 5/29/15.
//  Copyright (c) 2015 The Blueprint Project. All rights reserved.
//

#import "BPApi.h"
#import "BPHTTP.h"
#import "BPSession.h"
#import "BPAuth.h"
#import "BPConfig.h"

@implementation BPApi

static NSMutableArray *multiplexed_request_pool;
static bool multiplexed_requests_enabled;
static bool multiplexed_requests_active;

static int multiplexed_request_idle_time;
static int multiplexed_request_max_time;

static NSTimer *multiplexed_request_idle_timer;
static NSTimer *multiplexed_request_max_timer;

static NSMutableDictionary *pending_requests;

typedef void (^bphttp_block)(NSError *, id data);

+(void)post:(NSString *)path
   withData:(NSDictionary *)data
   andBlock:(void(^)(NSError *error, id responseObject))block
{
    [self post:path withData:data authenticated:YES andBlock:block];
}

+(void)put:(NSString *)path
  withData:(NSDictionary *)data
  andBlock:(void(^)(NSError *error, id responseObject))block
{
    [self put:path withData:data authenticated:YES andBlock:block];
}

+(void)post:(NSString *)path
   withData:(NSDictionary *)data
authenticated:(BOOL)authenticated
   andBlock:(void(^)(NSError *error, id responseObject))block
{
    @synchronized (pending_requests) {
        if(pending_requests == nil) {
            pending_requests = @{}.mutableCopy;
        }
        
        NSString *request_string = [NSString stringWithFormat:@"%@%@", path, data];
        
        NSMutableArray *blocks = @[block].mutableCopy;
        
        if(pending_requests[request_string] != nil) {
            [pending_requests[request_string] addObjectsFromArray:blocks];
        } else if(multiplexed_requests_enabled &&
                  ([path containsString:@"/query"] || [path containsString:@"/subscribe"])) {
            [BPApi addMultiplexedRequest:@{
                @"request_string": request_string,
                @"path": path,
                @"data": data,
            }];
            
            pending_requests[request_string] = blocks;
        } else {
            [BPApi sendRequestWithPath:path
                                method:@"POST"
                                  data:data
                         authenticated:authenticated
                              andBlock:^(NSError *error, id data) {
                                  @synchronized (pending_requests) {

                                      if(pending_requests[request_string] != nil) {
                                          for(bphttp_block block in pending_requests[request_string]) {
                                              block(error, data);
                                          }
                                          
                                          pending_requests[request_string] = nil;
                                      }
                                  }
                              }];
            
            pending_requests[request_string] = blocks;
        }
    }
}

+(void)put:(NSString *)path
  withData:(NSDictionary *)data
authenticated:(BOOL)authenticated
  andBlock:(void(^)(NSError *error, id responseObject))block
{
    [BPApi sendRequestWithPath:path
                        method:@"PUT"
                          data:data
                 authenticated:authenticated
                      andBlock:block];
}

// Private Helper Methods

+(void)sendRequestWithPath:(NSString *)path
                   method:(NSString *)method
                     data:(NSDictionary *)data
             authenticated:(BOOL)authenticated
                 andBlock:(void(^)(NSError *error, id data))block
{
    NSURL *url = [BPApi buildURLWithPath:path];
    
    NSMutableDictionary *request_data = @{@"request":data}.mutableCopy;
    
    if(authenticated && [BPSession objectForKey:@"auth_token"] != nil) {
        request_data = [BPAuth signRequest:request_data path:url.path andMethod:method];
    }
    
    [BPHTTP sendRequestWithURL:url method:method data:request_data andBlock:block];
}

+(NSURL *)buildURLWithPath:(NSString *)path
{
    NSString *url;
    
    url = [NSString stringWithFormat:@"%@://%@:%@/%@/%@",
        [BPConfig protocol],
        [BPConfig host],
        [BPConfig port],
        [BPConfig application_id],
        path];

    return [[NSURL alloc] initWithString:url];
}

#pragma mark - Multiplexed Requests

+(void)addMultiplexedRequest:(NSDictionary *)request
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(multiplexed_request_idle_timer) {
            [multiplexed_request_idle_timer invalidate];
        }
        
        multiplexed_request_idle_timer = [NSTimer scheduledTimerWithTimeInterval:multiplexed_request_idle_time/1000 target:self selector:@selector(runMultiplexedRequests) userInfo:nil repeats:NO];
        
        if(multiplexed_request_max_timer == nil) {
            multiplexed_request_max_timer = [NSTimer scheduledTimerWithTimeInterval:multiplexed_request_max_time/1000 target:self selector:@selector(runMultiplexedRequests) userInfo:nil repeats:NO];
        }
    });
    
    @synchronized (multiplexed_request_pool) {
        multiplexed_requests_active = YES;
        
        if(multiplexed_request_pool == nil) {
            multiplexed_request_pool = @[].mutableCopy;
        }
        
        [multiplexed_request_pool addObject:request];
    }
}

+(void)enableMultiplexedRequestsWithIdleTime:(int)idle_time andMaxCollectionTime:(int)max_collection_time
{
    multiplexed_request_idle_time = idle_time;
    multiplexed_request_max_time = max_collection_time;
    multiplexed_requests_enabled = true;
}

+(void)runMultiplexedRequests
{
    [multiplexed_request_max_timer invalidate];
    [multiplexed_request_idle_timer invalidate];
    
    multiplexed_request_max_timer = nil;
    multiplexed_request_idle_timer = nil;
    
    multiplexed_requests_active = NO;
    
    @synchronized(multiplexed_request_pool) {
        [BPApi sendMultiplexedRequest:multiplexed_request_pool.mutableCopy];
        multiplexed_request_pool = @[].mutableCopy;
    }
}

+(void)disableMultiplexedRequests
{
    multiplexed_requests_enabled = NO;
    [BPApi runMultiplexedRequests];
}

+(void)sendMultiplexedRequest:(NSArray *)requests
{
    if(requests.count == 1) {
        NSString *request_string = [NSString stringWithFormat:@"%@%@", requests[0][@"path"], requests[0][@"data"]];

        [BPApi sendRequestWithPath:requests[0][@"path"]
                            method:@"POST"
                              data:requests[0][@"data"]
                     authenticated:YES
                          andBlock:^(NSError *error, id data) {
                              
          @synchronized (pending_requests) {
            if(pending_requests[request_string] != nil) {
                    for(bphttp_block block in pending_requests[request_string]) {
                        block(error, data);
                    }
                    
                    pending_requests[request_string] = nil;
                }
            }
                              
        }];
    } else if(requests.count != 0) {
        NSMutableArray *formatted_requests = @[].mutableCopy;
        
        NSMutableArray *guid_array = @[].mutableCopy;
        
        for(NSDictionary *request in requests) {
            NSString *guid = [NSUUID UUID].UUIDString;

            if(guid && [request[@"path"] componentsSeparatedByString:@"/"][0] && request[@"data"]) {
                [formatted_requests addObject:@{
                    @"endpoint": [request[@"path"] componentsSeparatedByString:@"/"][0],
                    @"request": request[@"data"],
                    @"guid": guid
                }];
                
                [guid_array addObject:guid];
            }
        }
        
        NSDictionary *data = @{@"requests": formatted_requests}.mutableCopy;
        
        NSString *url_string = [NSString stringWithFormat:@"%@://%@:%@/%@/%@",
               [BPConfig protocol],
               [BPConfig host],
               [BPConfig port],
               [BPConfig application_id],
               @"multiplex"];

        NSURL *url = [NSURL URLWithString:url_string];
        
        NSMutableDictionary *request_data = @{@"request":data}.mutableCopy;
        
        if([BPSession objectForKey:@"auth_token"] != nil) {
            request_data = [BPAuth signRequest:request_data path:url.path andMethod:@"POST"];
        }
        
        [BPHTTP sendRequestWithURL:url method:@"POST" data:request_data andBlock:^(NSError *error, NSDictionary *data) {
            for(NSDictionary *request in requests) {
                NSString *request_string = [NSString stringWithFormat:@"%@%@", request[@"path"], request[@"data"]];
                NSString *guid = guid_array[[requests indexOfObject:request]];

                NSDictionary *response = nil;
                NSNumber *record_count = @(-1);
                
                if(data && data[@"response"] && data[@"response"][guid]) {
                    response = data[@"response"][guid];
                }
                
                NSString *record_count_key = [NSString stringWithFormat:@"%@.record_count", guid];
                
                if(data && data[@"meta"] && data[@"meta"][record_count_key]) {
                    record_count = data[@"meta"][record_count_key];
                }
                
                @synchronized (pending_requests) {

                    if(pending_requests[request_string] != nil) {
                        for(bphttp_block block in pending_requests[request_string]) {
                            if(response == nil) {
                                NSError *error = [[NSError alloc] initWithDomain:@"co.goblueprint.error"
                                                                            code:100
                                                                        userInfo:nil];
                                
                                block(error, @{});
                            } else {
                                NSDictionary *formatted_data = @{
                                    @"response": response,
                                    @"meta": @{
                                            @"record_count": record_count
                                    }
                                };
                                
                                block(error, formatted_data);
                            }
                        }
                        
                        pending_requests[request_string] = nil;
                    }
                }
            }
        }];
    }
}


@end

