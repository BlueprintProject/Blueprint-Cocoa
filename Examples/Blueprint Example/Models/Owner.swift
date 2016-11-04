//
//  Owner.swift
//  Blueprint Example
//
//  Created by Hunter on 5/1/16.
//  Copyright © 2016 Blueprint Project. All rights reserved.
//

import Cocoa

class Owner: BPModel {

    func findPetWithName(_ name: String!) -> BPSingleRecordPromise {
        let query = ["name": name as NSObject, "$limit": 1 as NSObject] as [String: NSObject]
        return Pet.findOne(query)
    }
    
}
