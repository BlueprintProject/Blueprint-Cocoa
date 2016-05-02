//
//  Owner.swift
//  Blueprint Example
//
//  Created by Hunter on 5/1/16.
//  Copyright © 2016 Blueprint Project. All rights reserved.
//

import Cocoa

class Owner: BPModel {

    func findPetWithName(name: String!) -> BPSingleRecordPromise {
        let query = ["name": name, "$limit": 1] as [String: NSObject]
        return Pet.findOne(query)
    }
    
}
