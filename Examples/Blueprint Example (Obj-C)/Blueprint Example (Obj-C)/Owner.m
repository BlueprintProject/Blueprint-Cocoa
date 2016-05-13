//
//  Owner.m
//  Blueprint Example (Obj-C)
//
//  Created by Hunter on 5/12/16.
//  Copyright © 2016 Blueprint Project. All rights reserved.
//

#import "Owner.h"
#import "Pet.h"

@implementation Owner

-(BPSingleRecordPromise *)findPetWithName:(NSString *)name
{
    NSDictionary *query = @{@"name": name};
    return [Pet findOne:query];
}

@end
