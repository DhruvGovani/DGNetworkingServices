//
//  AppDelegate.swift
//  DGNetworkingServices
//
//  Created by Dhruv Govani on 22/08/20.
//  Copyright © 2020 Dhruv Govani. All rights reserved.
//

import UIKit
import DGNetworkingServices

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        DGNetworkingServiceBaseUrl = "https://jsonplaceholder.typicode.com/"
        
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle


}

