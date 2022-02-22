//
//  AppDelegate.swift
//  ExampleProject
//
//  Created by Dhruv Govani on 25/10/20.
//  Copyright © 2020 Dhruv Govani. All rights reserved.
//

import UIKit
import DGNetworkingServices

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        DGNetworkingServiceBaseUrl = "https://reqres.in"
        DGNetworkingServiceAPIVersion = "/api/"
        DGDefaultHeaders = ["Timezone" : "IST"]
        DGNetworkLogs.shared.logging = .init(logRequest: true, logResponse: true)
        DGNetworkingServices.main.AdditionalRequestSettings.PrintResponseOnFail = true
        //Setup BaseUrl Here
        
        
        
        // Override point for customization after application launch.
        return true
    }


}

