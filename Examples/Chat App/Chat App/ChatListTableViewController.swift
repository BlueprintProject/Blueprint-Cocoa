//
//  ChatListTableViewController.swift
//  Chat App
//
//  Created by Hunter on 5/15/16.
//  Copyright © 2016 Blueprint Project. All rights reserved.
//

import UIKit

class ChatListTableViewController: UITableViewController {

    var chatPromise: BPMultiRecordPromise?
    var chats: [Chat]?
    
    // MARK: Data Loaders
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.chatPromise = Chat.find([:])
        self.tableView.dataSource = self;
        self.reload()
    }
    
    
    func reload() {
        self.chatPromise?.then({ (chats) in
            self.chats = chats as? [Chat]
            self.tableView.reloadData()
        }).subscribe(withKey: "all_chats").on({ (event, chats) in
            self.chats = chats as? [Chat]
            self.tableView.reloadData()
        }).fail({ (error) in
            print(error)
        })
        
    }
    
    
    // MARK: UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 && self.chats != nil {
            return self.chats!.count;
        }
        
        return 0;
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let chat = (self.chats?[(indexPath as NSIndexPath).row])
        
        if(chat != nil) {
            return chat!.listViewCellHeight()
        }
        
        return 0.0;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chat = (self.chats?[(indexPath as NSIndexPath).row])

        if (indexPath as NSIndexPath).section == 0 && chat != 0 {
            return chat!.listViewCell()
        }
        
        return UITableViewCell()
    }
    
}
