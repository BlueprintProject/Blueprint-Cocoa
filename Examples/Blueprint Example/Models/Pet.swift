//
//  Pet.swift
//  Blueprint Example
//
//  Created by Hunter on 5/1/16.
//  Copyright © 2016 Blueprint Project. All rights reserved.
//

import Cocoa

class Pet: BPModel {

    func giveToy(_ toy: Toy) {
        var toy_ids = [String]();
        
        if self["toy_ids"] != nil {
            toy_ids = self["toy_ids"] as! [String]
        }
        
        toy_ids.append(toy.objectId)
        
        self["toy_ids"] = toy_ids
    }
    
}
