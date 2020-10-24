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
    fileprivate func DownloadFile() {
        DGNetworkingServices.main.delegate = self
        
        DGNetworkingServices.main.downloadFile(Service: NetworkURL(withURL: "https://file-examples-com.github.io/uploads/2017/04/file_example_MP4_1920_18MG.mp4"), fileName: "TestVideo2", Extension: "mp4", headers: nil) { (Result) in
            switch Result{
            case .success(let FileURL):
                
                DispatchQueue.main.async {
                    DGNetworkingServices.main.SaveFileToPhotos(fileUrl: FileURL, Type: .Video) { (Status, error) in
                        if Status == true{
                            print("Item Downloaded and stored")
                        }else{
                            print(error?.localizedDescription ?? "Item Download Error")
                        }
                    }
                }
                
            case .failure(let Error):
                print(Error.rawValue)
            }
        }
    }
    
    fileprivate func GetData() {
        
        DGNetworkLogs.shared.logging.request = true
        DGNetworkLogs.shared.logging.response = true
        
        DGNetworkingServices.main.MakeApiCall(Service: NetworkURL(withURL: "https://jsonplaceholder.typicode.com/todos/1"), HttpMethod: .get, parameters: nil, headers: nil) { (Result) in
            switch Result{
            case .success((let res, _)):
                print(res)
                DGNetworkLogs.shared.PrintNetworkLogs(filterByUrl: nil, filterByStatusCode: nil)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DownloadFile()

        GetData()
        
    }
}

extension ViewController : DGNetworkingServicesDelegate{
    func didProggressed(_ ProgressDone: Double) {
        print(ProgressDone)
    }
    
}
