//
//  BPSubscriptionManager.h
//  Blueprint
//
//  Created by Hunter on 5/13/16.
//  Copyright © 2016 Blueprint Project. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BPMultiRecordPromise.h"

@interface BPSubscriptionManager : NSObject

typedef void (^BPSubscriptionManagerQueryResponseBlock)(NSString *event, NSArray<BPRecord *> *records);
typedef void (^BPSubscriptionManagerRecordResponseBlock)(NSString *event, BPRecord *record);

+(void)subscribeToQuery:(NSDictionary *)query
            forEndpoint:(NSString *)endpoint
               andEvent:(NSString *)event
              withBlock:(BPSubscriptionManagerQueryResponseBlock)block;

+(void)subscribeToRecord:(BPRecord *)record
               forEvent:(NSString *)event
              withBlock:(BPSubscriptionManagerRecordResponseBlock)block;

@end
