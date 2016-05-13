//
//  BPProfile.m
//  Pongtopia
//
//  Created by Hunter on 6/7/15.
//  Copyright (c) 2015 Uberpong. All rights reserved.
//

#import "BPProfile.h"

@implementation BPProfile

+(NSString *)endpointName
{
    return @"profiles";
}

+(BPSingleRecordPromise *)getProfileForUserWithId:(NSString *)user_id
{
    return [[self class] findOne:@{@"created_by": user_id}];
}
@end
