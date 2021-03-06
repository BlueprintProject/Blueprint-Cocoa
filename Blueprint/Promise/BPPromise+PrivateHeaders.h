//
//  BPPromise+PrivateHeaders.h
//  Blueprint
//
//  Created by Hunter on 5/1/16.
//  Copyright © 2016 Blueprint Project. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BPSingleRecordPromise.h"
#import "BPMultiRecordPromise.h"

#import "BPRecord.h"
#import "BPError.h"

@interface BPSingleRecordPromise()
@property (strong) NSObject *_Nonnull query;
@property (strong) NSString *_Nonnull endpoint;
@property (strong) Class _Nonnull modelClass;

-(void)completeWith:(BPRecord * _Nullable)record andError:(NSError * _Nullable)error;

@end

@interface BPMultiRecordPromise()

-(void)completeWith:(NSArray<BPRecord*> * _Nullable)records andError:(NSError * _Nullable)error;
@property (strong) NSObject *_Nonnull query;
@property (strong) NSString *_Nonnull endpoint;
@property (strong) Class _Nonnull modelClass;

@end

@interface BPPromise()

-(void)completeWithError:(NSError * _Nullable)error;

@end
