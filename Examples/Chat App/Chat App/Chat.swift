//
//  Chat.swift
//  Chat App
//
//  Created by Hunter on 5/15/16.
//  Copyright © 2016 Blueprint Project. All rights reserved.
//

import UIKit

class Chat: BPModel {
    
    // Data Loading
    
    class func getChats() -> BPMultiRecordPromise {
        return Chat.find([:])
    }
    
    // List View
    func listViewCellHeight() -> CGFloat {
        return 50.0
    }
    
    func listViewCell() -> UITableViewCell {
        return UITableViewCell()
    }
    
    // Message View
    
    
}
