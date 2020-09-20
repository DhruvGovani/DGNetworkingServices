//
//  ViewController.swift
//  DGNetworkingServices
//
//  Created by Dhruv Govani on 22/08/20.
//  Copyright © 2020 Dhruv Govani. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    deinit {
        print("ViewController")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DGNetworkLogs.shared.logging.request = true
        DGNetworkLogs.shared.logging.response = true
        
        DGNetworkingServices.main.MakeApiCall(Service: NetworkURL(withURL: "https://jsonplaceholder.typicode.com/todos/1"), HttpMethod: .get, parameters: nil, headers: nil) { (Result) in
            
            switch Result{
            case .success(let Response):
                print(Response.0)
                DGNetworkLogs.shared.PrintNetworkLogs(filterByUrl: nil, filterByStatusCode: nil)
            case .failure(let error):
                print(error.rawValue)
            }
            
            
        }

        
    }
}

