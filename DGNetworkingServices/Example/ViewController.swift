//
//  ViewController.swift
//  DGNetworkingServices
//
//  Created by Dhruv Govani on 22/08/20.
//  Copyright © 2020 Dhruv Govani. All rights reserved.
//

import UIKit
import DGNetworkingServices

class ViewController: UIViewController {
    deinit {
        print("ViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DGNetworkingServices.main.MakeApiCall(Service: NetworkURL(withService: "todos/1"), Attachments: nil, HttpMethod: .get, parameters: nil, headers: nil) { (Result) in
            switch Result{
            case .success((let res, _)):
                print(res)
            case .failure(let error):
                print(error)
            }
        }
        
    }
}
