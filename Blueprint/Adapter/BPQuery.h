//
//  BPQuery.h
//  Blueprint-Cocoa
//
//  Created by Waruna de Silva on 6/1/15.
//  Copyright (c) 2015 The Blueprint Project. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BPRecord.h"

@interface BPQuery : NSObject

typedef void (^bpquery_completion_block)(NSError *error, NSArray *objects);

@property (nonatomic, strong, readonly) NSString *endpoint;

+ (BPQuery *)queryForEndpoint:(NSString *)name;
- (void)setQuery:(NSDictionary *)where withBlock:(bpquery_completion_block)completionBlock;
- (void)setQueryKey:(NSString *)key to:(NSObject *)value;
- (void)execute;
- (NSString *)cacheKey;

@end
