//
//  BPCache.m
//  Blueprint
//
//  Created by Hunter on 10/24/16.
//  Copyright © 2016 Blueprint Project. All rights reserved.
//

#import "BPCache.h"

@implementation BPCache

static NSMutableDictionary *cacheDictionary;

+(BPMultiRecordPromise *)checkCache:(BPQuery *)query
{
    if(cacheDictionary) {
        @synchronized (cacheDictionary) {
            NSString *key = query.cacheKey;
            NSDictionary *cacheItem = cacheDictionary[key];
            
            if(cacheItem) {

                if([(NSDate *)cacheItem[@"expiration"] timeIntervalSinceNow] < 0) {
                    return cacheDictionary[@"object"];
                } else {
                    [cacheDictionary removeObjectForKey:key];
                }
            }
        }
    }
    
    return nil;
}

+(void)setPromise:(BPMultiRecordPromise *)promise forQuery:(BPQuery *)query withExpirationTime:(int)expirationTime
{
    if(!cacheDictionary) {
        cacheDictionary = @{}.mutableCopy;
    }
    
    @synchronized (cacheDictionary) {
        cacheDictionary[query.cacheKey] = @{
            @"expiration": [NSDate dateWithTimeIntervalSinceNow:expirationTime],
            @"object": promise
        };
    }
}


@end
