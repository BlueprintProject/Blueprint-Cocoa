//
//  SFRecord.h
//  The Blueprint Project
//
//  Created by Waruna de Silva on 5/19/15.
//  Copyright (c) 2015 Waruna. All rights reserved.
//

#import "BPObject.h"
#import "BPGroup.h"
#import "BPFile.h"
#import "BPPromise.h"

@interface BPRecord : BPObject
{
    @protected
    
}

typedef void (^BPSingleRecordSuccessBlock)(BPRecord * _Nonnull record);
typedef void (^BPSingleRecordEventBlock)(NSString *_Nonnull event, BPRecord * _Nonnull record);
typedef void (^BPSingleRecordFailBlock)(NSError * _Nonnull error);

@property (nonatomic, retain) NSMutableDictionary * _Nonnull content;
@property (nonatomic, retain) NSMutableDictionary * _Nonnull files;
@property (nonatomic, strong) NSNumber * _Nullable updatedAtNumber;
@property (nonatomic, strong) NSNumber * _Nullable createdAtNumber;
@property (nonatomic, strong) NSString * _Nonnull createdById;
@property (nonatomic, retain) NSMutableDictionary * _Nonnull permissions;

@property BOOL canWrite;
@property BOOL canDestroy;

+ (BPRecord * _Nonnull)recordWithEndpointName:(NSString * _Nonnull)name;
+ (instancetype _Nonnull)recordWithEndpointName:(NSString * _Nonnull)name andContent:(NSDictionary * _Nonnull)content;

- (void)saveWithBlock:(void (^ _Nonnull)(NSError * _Nullable error))completionBlock;
- (void)destroyRecordWithBlock:(void (^ _Nonnull)(NSError * _Nullable error))completionBlock;

- (void)setObject:(id _Nonnull)object forKey:(NSString * _Nonnull)key;
- (id _Nullable)objectForKey:(NSString * _Nonnull)key;

- (void)setGroups:(NSDictionary * _Nonnull)permissions;
- (void)setReadGroups:(NSArray * _Nonnull)readGroups;
- (void)setWriteGroups:(NSArray * _Nonnull)writeGroups;
- (void)setDestroyGroups:(NSArray * _Nonnull)destroyGroups;

- (void)addReadGroup:(BPGroup * _Nonnull)group;
- (void)addWriteGroup:(BPGroup * _Nonnull)group;
- (void)addDestroyGroup:(BPGroup * _Nonnull)group;
- (void)removeReadGroup:(BPGroup * _Nonnull)group;
- (void)removeWriteGroup:(BPGroup * _Nonnull)group;
- (void)removeDestroyGroup:(BPGroup * _Nonnull)group;

-(BPPromise * _Nonnull)uploadFileWithData:(NSData *_Nonnull)data
                            name:(NSString *_Nonnull)name;

- (BPFile * _Nullable)fileWithName:(NSString * _Nonnull)file;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray * _Nullable allKeys;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDate * _Nullable updatedAt;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDate * _Nullable createdAt;

- (void)saveAsUnauthenticatedUserWithBlock:(void (^_Nonnull)(NSError * _Nullable))completionBlock;

// Promise Based
-(BPPromise * _Nonnull)save;

#pragma mark - Subscriptions
-(void)on:(BPSingleRecordEventBlock _Nonnull)block;
-(void)onUpdate:(BPSingleRecordSuccessBlock _Nonnull)block;
-(void)onDestroy:(BPSingleRecordSuccessBlock _Nonnull)block;

@end
