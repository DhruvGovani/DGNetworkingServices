//
//  DGNetworkingServicesTests.swift
//  DGNetworkingServicesTests
//
//  Created by Dhruv Govani on 24/10/20.
//  Copyright © 2020 Dhruv Govani. All rights reserved.
//

import XCTest
@testable import DGNetworkingServices

class DGNetworkingServicesTests: XCTestCase, DGNetworkingServicesDelegate {
    func didProggressed(_ ProgressDone: Double) {
        print(ProgressDone)
    }
    
    
    override class func setUp() {
    }
    
    
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testGet() {
        
        DGNetworkingServices.main.MakeApiCall(Service: NetworkURL(withURL: "https://jsonplaceholder.typicode.com/todos/1"), HttpMethod: .get, parameters: nil, headers: nil) { (Result) in
            switch Result{
            case .success((let dict, _)):
                print(dict)
            case .failure(let error):
                print(error)
            }
        }
        
    }
    
    func testGetWithLof() {
        
        DGNetworkLogs.shared.logging.request = true
        DGNetworkLogs.shared.logging.response = true
        
        DGNetworkLogs.shared.setLog(url: "test", statusCode: 200, parameters: ["hey" : 1], headers: ["test" : "test"], response: ["hey" : 1], message: "good", Method: "test")
        
        DGNetworkingServices.main.MakeApiCall(Service: NetworkURL(withURL: "https://jsonplaceholder.typicode.com/todos/1"), HttpMethod: .get, parameters: nil, headers: nil) { (Result) in
            switch Result{
            case .success((let dict, let data)):
                print(dict)
                print(DGNetworkingServices.main.toJSON(data: data)!)
                DGNetworkLogs.shared.PrintNetworkLogs(filterByUrl: nil, filterByStatusCode: nil)
            case .failure(let error):
                print(error)
            }
        }
        
    }
    
    func testGetWithMedia() {
        
        DGNetworkingServices.main.MakeApiCall(Service: NetworkURL(withURL: "https://jsonplaceholder.typicode.com/todos/1"), Attachments: nil, HttpMethod: .get, parameters: nil, headers: nil) { (Result) in
            switch Result{
            case .success((let dict, _)):
                print(dict)
            case .failure(let error):
                print(error)
            }
        }
        
    }
    
    func testDownloadFile(){
        
        DGNetworkingServices.main.delegate = self
        
        print(DGNetworkingServices.main.GetMimeType(FileExtension: "png") ?? "error")
        
        DGNetworkingServices.main.downloadFile(Service: NetworkURL(withURL: "https://file-examples-com.github.io/uploads/2017/10/file_example_PNG_500kB.png"), fileName: "test", Extension: ".png", headers: nil) { (Result) in
            switch Result{
            case .success(let url):
                print(url)
                
                DGNetworkingServices.main.SaveFileToPhotos(fileUrl: url, Type: .Photo) { (status, error) in
                    print(error.debugDescription)
                    print(status)
                }
                

            case .failure(let error):
                print(error)
            }
        }
        
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
