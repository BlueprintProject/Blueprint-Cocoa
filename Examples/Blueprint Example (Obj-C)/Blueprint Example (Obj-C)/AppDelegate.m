//
//  AppDelegate.m
//  Blueprint Example (Obj-C)
//
//  Created by Hunter on 5/12/16.
//  Copyright © 2016 Blueprint Project. All rights reserved.
//

#import "AppDelegate.h"

#import <Blueprint/Blueprint.h>
#import "Owner.h"
#import "Pet.h"
#import "Toy.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [Blueprint setConfig:@{@"host":@"localhost", @"port":@8080}];
    [Blueprint enableBulkRequestsWithIdleTime:10 andMaxCollectionTime:100];
    
    [[Owner findOne:@{@"name":@"Hunter"}] then:^(BPRecord * _Nonnull record) {
        
        Owner *owner = (Owner *)record;
        
        [[owner findPetWithName:@"Wiley"] then:^(BPRecord * _Nonnull record) {
            Pet *pet = (Pet *)record;
            
            Toy *toy = [Toy new];
            toy[@"kind"] = @"Ball";
            toy[@"price"] = @2.79;
            
            [[toy save] then:^{
                [pet giveToy:toy];
               
                [[pet save] then:^{
                    NSLog(@"Done!");
                }];
            }];
        }];
    }];
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
