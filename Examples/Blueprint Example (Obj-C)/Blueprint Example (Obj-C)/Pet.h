//
//  Pet.h
//  Blueprint Example (Obj-C)
//
//  Created by Hunter on 5/12/16.
//  Copyright © 2016 Blueprint Project. All rights reserved.
//

#import <Blueprint/Blueprint.h>
#import "Toy.h"

@interface Pet : BPModel

-(void)giveToy:(Toy *)toy;

@end
