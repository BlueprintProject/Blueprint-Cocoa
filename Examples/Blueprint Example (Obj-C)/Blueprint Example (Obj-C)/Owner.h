//
//  Owner.h
//  Blueprint Example (Obj-C)
//
//  Created by Hunter on 5/12/16.
//  Copyright © 2016 Blueprint Project. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Blueprint/Blueprint.h>

@interface Owner : BPModel

-(BPSingleRecordPromise *)findPetWithName:(NSString *)name;

@end
