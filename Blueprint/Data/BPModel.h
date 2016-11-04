//
//  BPModel.h
//  Blueprint-Cocoa
//
//  Created by Hunter Dolan on 6/3/15.
//  Copyright (c) 2015 The Blueprint Project. All rights reserved.
//

#import "BPRecord.h"

#import "BPMultiRecordPromise.h"
#import "BPSingleRecordPromise.h"

@interface BPModel : BPRecord

typedef void (^BPSingleRecordResponseBlock)(NSError * _Nullable error, BPRecord * _Nullable record);
typedef void (^BPMultiRecordResponseBlock)(NSError * _Nullable error, NSArray<BPRecord*> * _Nullable records);

+(NSString * _Nonnull)endpointName;

- (instancetype _Nonnull)init:(NSDictionary * _Nonnull)dictionary;

// Promise Based
+ (BPMultiRecordPromise * _Nonnull)find:(NSDictionary<NSString*, id> * _Nonnull)where;
+ (BPSingleRecordPromise * _Nonnull)findById:(NSString * _Nonnull)_id;
+ (BPSingleRecordPromise * _Nonnull)findOne:(NSDictionary<NSString*, id> * _Nonnull)where;

// Record
+(instancetype _Nonnull)recordWithContent:(NSDictionary<NSString*, id> * _Nonnull)content;

@end
