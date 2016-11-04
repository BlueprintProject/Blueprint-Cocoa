//
//  BPSingleRecordPromise.h
//  Blueprint
//
//  Created by Hunter on 5/1/16.
//  Copyright © 2016 Blueprint Project. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BPError.h"
#import "BPObject.h"

@interface BPSingleRecordPromise : NSObject

typedef void (^BPSingleRecordSuccessBlock)(id _Nonnull record);
typedef void (^BPSingleRecordEventBlock)(NSString *_Nonnull event, id _Nonnull record);
typedef void (^BPSingleRecordFailBlock)(NSError * _Nonnull error);

-(BPSingleRecordPromise * _Nonnull)then:(BPSingleRecordSuccessBlock _Nonnull)block;
-(BPSingleRecordPromise  * _Nonnull)fail:(BPSingleRecordFailBlock _Nonnull)block;

-(BPSingleRecordPromise * _Nonnull)cache:(int)seconds;

#pragma mark - Subscriptions
-(BPSingleRecordPromise * _Nonnull)on:(BPSingleRecordEventBlock _Nonnull)block;
-(BPSingleRecordPromise * _Nonnull)onUpdate:(BPSingleRecordSuccessBlock _Nonnull)block;
-(BPSingleRecordPromise * _Nonnull)onDestroy:(BPSingleRecordSuccessBlock _Nonnull)block;

@end
