//
//  BPCache.h
//  Blueprint
//
//  Created by Hunter on 10/24/16.
//  Copyright © 2016 Blueprint Project. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BPPromise+PrivateHeaders.h"
#import "BPQuery.h"

@interface BPCache : NSObject

+(BPMultiRecordPromise *)checkCache:(BPQuery *)query;
+(void)setPromise:(BPMultiRecordPromise *)promise forQuery:(BPQuery *)query withExpirationTime:(int)expirationTime;

@end
