//
//  ViewController.swift
//  ExampleProject
//
//  Created by Dhruv Govani on 25/10/20.
//  Copyright © 2020 Dhruv Govani. All rights reserved.
//

import UIKit
import DGNetworkingServices

struct TestModel: Codable {
    let page, perPage, total, totalPages: Int?
    let data: [Datum]?
    let ad: Ad?

    enum CodingKeys: String, CodingKey {
        case page
        case perPage = "per_page"
        case total
        case totalPages = "total_pages"
        case data, ad
    }
}

// MARK: - Ad
struct Ad: Codable {
    let company: String?
    let url: String?
    let text: String?
}

// MARK: - Datum
struct Datum: Codable {
    let id: Int?
    let email, firstName, lastName: String?
    let avatar: String?

    enum CodingKeys: String, CodingKey {
        case id, email
        case firstName = "first_name"
        case lastName = "last_name"
        case avatar
    }
}

class ViewController: UIViewController {

    
    func triggerServerError(){
        
        DGNetworkingServices.main.MakeApiCall(Service: NetworkURL(withURL: "https://triggererror.free.beeceptor.com/my/api/triggerServerError"), HttpMethod: .get, parameters: nil, headers: nil) { (Result) in
            
            switch Result{
            case .success((_, _)):
                print("success")
            case .failure(let error):
                print(error.rawValue)
            }
            
        }
        
    }
    
    func DirectDecodableGetUserDataWithStoredUrl(){
        
        DGNetworkingServices.main.MakeApiCall(Service: NetworkURL(withService: "users?page=2"), HttpMethod: .get, parameters: nil, headers: nil, Codable: TestModel.self) { (Result) in
            switch Result{
            case .success(let Response):
                print(Response)
                
            case .failure(let error):
                print(error)
                
            }
        }
        
    }
    
    func GetUserDataWithStoredUrl(){
        
        // Initialised this two vars in the AppDelegate.swift
        
//        DGNetworkingServiceBaseUrl = "https://reqres.in"
//        DGNetworkingServiceAPIVersion = "/api/"
        
        DGNetworkingServices.main.MakeApiCall(Service: NetworkURL(withService: "users?page=2"), HttpMethod: .get, parameters: nil, headers: nil) { (Result) in
            
            switch Result{
            case .success((let ResponseInDict, let ResponseInData)):
                
                //Prinitng direct JSON Dict
                print(ResponseInDict)
                
                // Decoding the Data into perticular Modle
                do{
                    let DecodedResponse = try JSONDecoder().decode(TestModel.self, from: ResponseInData)
                    
                    print(DecodedResponse)
                                        
                }catch{
                    
                    // Error if anything Goes Wrong While Decoding
                    print(error)
                    
                }
                
            case .failure(let Error):
                print(Error.rawValue)
            }
            
        }
        
    }
    
    func GetUserDataWithFullUrl(){
        
        
        DGNetworkingServices.main.MakeApiCall(Service: NetworkURL(withURL: "https://reqres.in/api/users?page=2"), HttpMethod: .get, parameters: nil, headers: nil) { (Result) in
            
            switch Result{
            case .success((let ResponseInDict, let ResponseInData)):
                
                //Prinitng direct JSON Dict
                print(ResponseInDict)
                
                // Decoding the Data into perticular Modle
                do{
                    let DecodedResponse = try JSONDecoder().decode(TestModel.self, from: ResponseInData)
                    
                    print(DecodedResponse)
                                        
                }catch{
                    
                    // Error if anything Goes Wrong While Decoding
                    print(error)
                    
                }
                
            case .failure(let Error):
                print(Error.rawValue)
            }
            
        }
        
    }
    
    func NotFoundError(){
        
        DGNetworkingServices.main.MakeApiCall(Service: NetworkURL(withService: "users/23"), HttpMethod: .get, parameters: nil, headers: nil) { (Result) in
            switch Result{
            case .success((let Response, _)):
                print(Response)
            case .failure(let Error):
                print(Error.rawValue)
            }
        }
        
    }
    
    func PostUser(){
        
        //Key Must be String, value can be anything that server can process
        let params : [String : Any] = ["name": "morpheus",
                                       "job": "leader"]
        
        DGNetworkingServices.main.MakeApiCall(Service: NetworkURL(withService: "users"), HttpMethod: .post, parameters: params, headers: nil) { (Result) in
            
            
            switch Result{
            case .success((let Response, _)):
                print(Response)
            case .failure(let Error):
                print(Error.rawValue)
            }
            
        }
        
        
    }
    
    func PostUserWithLogging(){
        
        // Set Logging as True to log the request or response or both
        // Only Use for the Debugging purpose please
        // The logs will be destroyed each session for security reasons
        DGNetworkLogs.shared.logging = Log(logRequest: true, logResponse: true)
        
        let params : [String : Any] = ["name": "morpheus",
                                       "job": "leader"]
        
        DGNetworkingServices.main.MakeApiCall(Service: NetworkURL(withService: "users"), HttpMethod: .post, parameters: params, headers: nil) { (Result) in
            
            
            switch Result{
            case .success((let Response, _)):
                print(Response)
            case .failure(let Error):
                print(Error.rawValue)
            }
            // Print the logged Calls
//            DGNetworkLogs.shared.PrintNetworkLogs(filterByUrl: nil, filterByStatusCode: nil)
            
        }
    }
    
    func DeletUser(){
        DGNetworkingServices.main.MakeApiCall(Service: NetworkURL(withService: "users/2"), HttpMethod: .delete, parameters: nil, headers: nil) { (Result) in
            switch Result{
            case .success((let res, _)):
                print(res)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func HeaderExample(){
        
        let headers : [String : String] = ["my-sample-header" : "hello world!"]
        
        DGNetworkingServices.main.MakeApiCall(Service: NetworkURL(withURL: "https://postman-echo.com/headers"), Attachments: nil, HttpMethod: .get, parameters: nil, headers: headers) { (Result) in
            
            switch Result{
            case .success((let Response, _)):
                
                //Serialize the Dict
                let ResHeaders = Response["headers"] as? [String : Any] ?? [:]
                
                print(ResHeaders["my-sample-header"] as! String)
                
//                print(DGNetworkLogs.shared.PrintNetworkLogs(filterByUrl: nil, filterByStatusCode: 200))
                
            case .failure(let error):
                print(error.rawValue)
            }
            
        }
        
    }
    
    func DownloadAnImageAndStoreInGallary(){

        DGNetworkingServices.main.downloadFile(Service: NetworkURL(withURL: "https://file-examples-com.github.io/uploads/2017/10/file_example_JPG_100kB.jpg"), fileName: "TestImage", Extension: "jpg", headers: nil) { (Result) in
            
            
            switch Result{
            case .success(let Url):
                
                // Do not forget to add followings in yout info.plist
        //        <key>NSPhotoLibraryAddUsageDescription</key>
        //        <string>Permission Decription</string>
        //        <key>NSPhotoLibraryUsageDescription</key>
        //        <string>Permission Decription</string>
                
                DGNetworkingServices.main.SaveFileToPhotos(fileUrl: Url, Type: .Photo) { (status, error) in
                    if status == true{
                        print(status)
                        print("Open Gallary image has been saved")
                    }else{
                        print(error?.localizedDescription ?? "")
                    }
                }
                
            case .failure(let Error):
                print(Error.rawValue)
            }
            
        }
        
    }
    
    func DownloadLongVideo(){
//        https://file-examples-com.github.io/uploads/2017/04/file_example_MP4_1280_10MG.mp4
        DGNetworkingServices.main.delegate = self
        
        DGNetworkingServices.main.downloadFile(Service: NetworkURL(withURL: "https://file-examples-com.github.io/uploads/2017/04/file_example_MP4_1280_10MG.mp4"), fileName: "TestVideo", Extension: "mp4", headers: nil) { (Result) in
            
            switch Result{
            case .success(let Url):
                
                // Do not forget to add followings in yout info.plist
        //        <key>NSPhotoLibraryAddUsageDescription</key>
        //        <string>Permission Decription</string>
        //        <key>NSPhotoLibraryUsageDescription</key>
        //        <string>Permission Decription</string>
                
                DGNetworkingServices.main.SaveFileToPhotos(fileUrl: Url, Type: .Video) { (status, error) in
                    if status == true{
                        print(status)
                        print("Open Gallary Video has been saved")
                    }else{
                        print(error?.localizedDescription ?? "")
                    }
                }
                
            case .failure(let Error):
                print(Error.rawValue)
            }
            
        }
    }
    
    
    func ApiCallWithMedia(){
        
        // Create a Array of Media like this
        let Images : [Media?]? = [
            
            Media(withJPEGImage: UIImage(named: "imageNameHere")!, forKey: "keyHere", compression: .medium)
        
        ]
        
        // i did not find any api for image upload so you have to use you own here
        DGNetworkingServices.main.MakeApiCall(Service: NetworkURL(withService: ""), Attachments: Images, HttpMethod: .post, parameters: nil, headers: nil) { (Result) in
            
            switch Result{
            
            case .success((let Res, _)):
                print(Res)
            case .failure(let error):
                print(error.rawValue)
            }
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        triggerServerError()
               
        // Do any additional setup after loading the view.
    }

    @IBAction func ButtonAction(_ sender: UIButton) {
        
        switch sender.tag {
        case 0:
            print("--------------")
            print("GetUserDataWithStoredUrl")
            print("--------------")

            DirectDecodableGetUserDataWithStoredUrl()
        case 1:
            print("--------------")
            print("GetUserDataWithStoredUrl")
            print("--------------")
            GetUserDataWithStoredUrl()
        case 2:
            print("--------------")
            print("NotFoundError")
            print("--------------")
            NotFoundError()
        case 3:
            print("--------------")
            print("PostUser")
            print("--------------")
            PostUser()
        case 4:
            print("--------------")
            print("PostUserWithLogging")
            print("--------------")
            PostUserWithLogging()
        case 5:
            print("--------------")
            print("DeletUser")
            print("--------------")
            DeletUser()
        case 6:
            print("--------------")
            print("HeaderExample")
            print("--------------")
            HeaderExample()
        case 7:
            print("--------------")
            print("DownloadAnImageAndStoreInGallary")
            print("--------------")
            DownloadAnImageAndStoreInGallary()
        case 8:
            print("--------------")
            print("DownloadLongVideo")
            print("--------------")
            DownloadLongVideo()
        default:
            print("default")
        }
        
    }
    
    
    

}


extension ViewController : DGNetworkingServicesDelegate{
    func didProggressed(_ ProgressDone: Double) {
        print(ProgressDone)
    }
}
