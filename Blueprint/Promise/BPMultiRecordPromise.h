//
//  BPMultiRecordPromise.h
//  Blueprint
//
//  Created by Hunter on 5/1/16.
//  Copyright © 2016 Blueprint Project. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BPRecord.h"

@interface BPMultiRecordPromise : NSObject

typedef void (^BPMultiRecordSuccessBlock)(NSArray<BPRecord *> * _Nonnull records);
typedef void (^BPMultiRecordEventBlock)(NSString *_Nonnull event, NSArray<BPRecord *> *_Nonnull records);
typedef void (^BPMultiRecordFailBlock)(NSError* _Nonnull error);

-(BPMultiRecordPromise * _Nonnull)then:(BPMultiRecordSuccessBlock _Nonnull)block;
-(BPMultiRecordPromise * _Nonnull)fail:(BPMultiRecordFailBlock _Nonnull)block;

#pragma mark - Subscriptions
-(BPMultiRecordPromise * _Nonnull)on:(BPMultiRecordEventBlock _Nonnull)block;
-(BPMultiRecordPromise * _Nonnull)onCreate:(BPMultiRecordSuccessBlock _Nonnull)block;
-(BPMultiRecordPromise * _Nonnull)onUpdate:(BPMultiRecordSuccessBlock _Nonnull)block;
-(BPMultiRecordPromise * _Nonnull)onDestroy:(BPMultiRecordSuccessBlock _Nonnull)block;

@end
