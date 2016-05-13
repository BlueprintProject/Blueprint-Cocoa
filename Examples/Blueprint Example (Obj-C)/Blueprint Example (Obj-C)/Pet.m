//
//  Pet.m
//  Blueprint Example (Obj-C)
//
//  Created by Hunter on 5/12/16.
//  Copyright © 2016 Blueprint Project. All rights reserved.
//

#import "Pet.h"

@implementation Pet

-(void)giveToy:(Toy *)toy
{
    NSMutableArray *toy_ids = @[].mutableCopy;
    
    if(self[@"toy_ids"] != nil) {
        toy_ids = [self[@"toy_ids"] mutableCopy];
    }
    
    [toy_ids addObject:toy.objectId];
    
    self[@"toy_ids"] = toy_ids;
}

@end
