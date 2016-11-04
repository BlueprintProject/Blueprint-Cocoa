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



    func applicationDidFinishLaunching(_ aNotification: Notification) {

        Blueprint.setConfig([
            "host": "localhost",
            "port": 8080
        ])
        
        /*
        Blueprint.authenticateWithEmail("hunterhdolan@gmail.com", password: "ginger7227").then { 
            print("HErele")
        }.fail { (err) in
            print("Aw")
        }
        */
        
        Blueprint.enableMultiplexedRequests(withIdleTime: 10, andMaxCollectionTime: 100)
        
        Blueprint.setErrorHandler { (error) -> Bool in
            print("An error occoured", error)
            
            return true;
        }

        Owner.findOne(["name": "Hunter" as NSObject]).then { (record) in
            let owner  = record as! Owner
            owner.findPetWithName("Wiley").then { (record) in
                let pet = record as! Pet
                
                let toy = Toy([
                    "kind": "Rope",
                    "price": 1.99
                ])

                
                toy.addSubscribeKey("wileys_toys")
                toy.addRead(Blueprint.publicGroup())

                toy.save().then {
                    pet.giveToy(toy)
                    pet.save().then {
                        //exit(0)
                    }
                }.fail { (error) in
                    print("Could not save toy")
                }
                
            }
        }

        Toy.find(["kind":"Ropee" as NSObject]).subscribe(withKey: "wileys_toys").onCreate { (record) in
            print(record)
        }
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

