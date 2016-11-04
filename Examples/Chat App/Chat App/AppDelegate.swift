//
//  AppDelegate.swift
//  Chat App
//
//  Created by Hunter on 5/15/16.
//  Copyright © 2016 Blueprint Project. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        Blueprint.setConfig([
            "host": "localhost",
            "port": 8080
        ])
        
        Blueprint.enableMultiplexedRequests(withIdleTime: 10, andMaxCollectionTime: 100)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {

    }

    func applicationDidEnterBackground(_ application: UIApplication) {

    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    
    }

    func applicationDidBecomeActive(_ application: UIApplication) {

    }

    func applicationWillTerminate(_ application: UIApplication) {

    }


}

