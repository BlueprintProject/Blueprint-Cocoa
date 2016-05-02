//
//  SFRequest.h
//  The Blueprint Project
//
//  Created by Waruna de Silva on 5/19/15.
//  Copyright (c) 2015 Waruna. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
    BPResponseStatusSuccess = 200,
    BPResponseStatusError = 400
};
typedef NSInteger BPResponseStatus;

@interface BPRequest : NSObject

@property (readonly, nonatomic, strong) NSURL *baseURL;
@property (nonatomic, strong) NSOperationQueue *operationQueue;

#if OS_OBJECT_HAVE_OBJC_SUPPORT
@property (nonatomic, strong) dispatch_group_t completionGroup;
#else
@property (nonatomic, assign) dispatch_group_t completionGroup;
#endif

+(void)sendRequestWithURL:(NSURL *)url
                   method:(NSString *)method
                     data:(NSDictionary *)data
                 andBlock:(void(^)(NSError *error, NSDictionary *data))block;


@end

