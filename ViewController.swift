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
        
        DGNetworkingServices.main.delegate = self
        
        DGNetworkingServices.main.downloadFile(Service: NetworkURL(withURL: "https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4"), fileName: "TestVideo", Extension: "mp4", headers: nil) { (Result) in
            switch Result{
            case .success(let URL):
                print(URL)
            case .failure(let Error):
                print(Error.rawValue)
            }
        }

        
    }
}

extension ViewController : DGNetworkingServicesDelegate{
    func didProggressed(_ ProgressDone: Double) {
        print(ProgressDone)
    }
    
}
