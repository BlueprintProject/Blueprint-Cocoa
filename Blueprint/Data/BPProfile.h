//
//  BPProfile.h
//  Pongtopia
//
//  Created by Hunter on 6/7/15.
//  Copyright (c) 2015 Uberpong. All rights reserved.
//

#import "BPSingleRecordPromise.h"
#import "BPModel.h"

@interface BPProfile : BPModel

+(BPSingleRecordPromise *)getProfileForUserWithId:(NSString *)user_id;

@end
