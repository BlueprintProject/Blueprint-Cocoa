//
//  AppDelegate.swift
//  Blueprint Example
//
//  Created by Hunter on 5/1/16.
//  Copyright © 2016 Blueprint Project. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(aNotification: NSNotification) {

        Blueprint.setConfig([
            "host": "localhost",
            "port": 8080
        ])
        
        Blueprint.enableBulkRequestsWithIdleTime(10, andMaxCollectionTime: 100)
        
        Blueprint.setErrorHandler { (error) -> Bool in
            print("An error occoured", error)
            
            return true;
        }

        Owner.findOne(["name": "Hunter"]).then { (record) in
            let owner  = record as! Owner
            owner.findPetWithName("Wiley").then { (record) in
                let pet = record as! Pet
                
                let toy = Toy([
                    "kind": "Rope",
                    "price": 1.99
                ])

                toy.addReadGroup(Blueprint.publicGroup())

                toy.save().then {
                    pet.giveToy(toy)
                    pet.save().then {
                        exit(0)
                    }
                }
            }
        }
        
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

