//
//  BPHTTP.m
//  The Blueprint Project
//
//  Created by Hunter Dolan on 5/29/15.
//  Copyright (c) 2015 The Blueprint Project. All rights reserved.
//

#import "BPHTTP.h"
#import "BPSession.h"
#import "BPAuth.h"
#import "BPError.h"

@implementation BPHTTP

+(void)sendRequestWithURL:(NSURL *)url
                   method:(NSString *)method
                     data:(NSDictionary *)request_data
                 andBlock:(void(^)(NSError *error, id responseObject))block
{
    [self sendRequestWithURL:url method:method
                        data:request_data
                  retryCount:0
                    andBlock:block];
}

+(void)resendRequestWithURL:(NSURL *)url
                   method:(NSString *)method
                     data:(NSDictionary *)request_data
               retryCount:(int)retry_count
                 andBlock:(void(^)(NSError *error, id responseObject))block
{
    BOOL authenticated = request_data[@"authorization"] != nil;
    
    if(authenticated && [BPSession objectForKey:@"auth_token"] != nil) {
        request_data = [BPAuth signRequest:@{@"request":request_data[@"request"]}.mutableCopy
                                      path:url.path
                                 andMethod:method];
    }
    
    [self sendRequestWithURL:url
                      method:method
                        data:request_data
                  retryCount:(retry_count+1)
                    andBlock:block];
}

+(void)sendRequestWithURL:(NSURL *)url
                  method:(NSString *)method
                    data:(NSDictionary *)request_data
               retryCount:(int)retry_count
                andBlock:(void(^)(NSError *error, id responseObject))block
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = method;
    
    NSError *json_serialize_error = nil;
    
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:request_data options:0 error:&json_serialize_error];

    if(json_serialize_error != nil) {
        block(json_serialize_error, nil);
    } else {
        NSURLSession *session = [NSURLSession sharedSession];

        NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData * _Nullable response_data, NSURLResponse * _Nullable response, NSError * _Nullable connectionError) {
            if(response_data == nil) {
                if(retry_count <= 2) {
                    [self resendRequestWithURL:url
                                        method:method
                                          data:request_data
                                    retryCount:(retry_count+1)
                                      andBlock:block];
                } else {
                    NSError *error = [[NSError alloc] initWithDomain:@"co.goblueprint.error"
                                                                code:2000
                                                            userInfo:nil];
                    if([BPHTTP handleError:error]) {
                        block(error, nil);
                    }
                }
            } else {
                
                NSError *json_read_error = nil;
                id response_object = [NSJSONSerialization JSONObjectWithData:response_data options:0 error:&json_read_error];

                if(json_read_error != nil) {
                    if([BPHTTP handleError:json_read_error]) {
                        block(json_read_error, nil);
                    }
                    
                } else {
                    if([response_object[@"error"] isEqualToNumber:@YES]) {
                        if(retry_count <= 2) {
                            [self resendRequestWithURL:url
                                              method:method
                                                data:request_data
                                          retryCount:(retry_count+1)
                                            andBlock:block];
                        } else {
                            
                            NSError *error = [[NSError alloc] initWithDomain:@"co.goblueprint.error"
                                                                        code:[response_object[@"response"][@"code"] integerValue]
                                                                    userInfo:response_object[@"response"]];
                            if([BPHTTP handleError:error]) {
                                block(error, response_object);
                            }
                        }
                    } else {
                        block(nil, response_object);
                    }
                }
            }
        }];
        
        [task resume];
    }
}

+(BOOL)handleError:(NSError *)error
{
    return [BPError handleError: error];
}

@end
