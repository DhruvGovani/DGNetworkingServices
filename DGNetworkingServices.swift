//
//  DGNetworkingServices.swift
//  Playground
//
//  Created by Dhruv Govani on 27/06/20.
//  Copyright © 2020 Dhruv Govani. All rights reserved.
//

import Foundation
import SystemConfiguration
import UIKit
import SystemConfiguration.CaptiveNetwork

protocol DGNetworkingServicesDelegate : AnyObject {
    func didProggressed(_ ProgressDone : Double)
}

///Compression Quality For Image
/// # CGFloats According to Cases
/// -  lowest  = 0
/// -  low     = 0.25
/// -  medium  = 0.5
/// -  high    = 0.75
/// -  highest = 1
enum JPEGQuality: CGFloat {
    case lowest  = 0
    case low     = 0.25
    case medium  = 0.5
    case high    = 0.75
    case highest = 1
}

struct Media {
    let key: String
    let fileName: String
    let data: Data
    let mimeType: String
    
    init?(withJPEGImage JpegImage: UIImage, forKey key: String, compression : JPEGQuality) {
        self.key = key
        self.mimeType = "image/jpg"
        self.fileName = "\(arc4random()).jpeg"
        
        guard let data = JpegImage.jpegData(compressionQuality: compression.rawValue) else { return nil }
        self.data = data
    }
    
    init?(withPNGImage pngImage: UIImage, forKey key: String) {
        self.key = key
        self.mimeType = "image/png"
        self.fileName = "\(arc4random()).png"
        
        guard let data = pngImage.pngData() else { return nil }
        self.data = data
    }
    
    init?(key : String, Media : Data?, mimeType : String, fileType : String){
        self.key = key
        self.mimeType = mimeType
        self.fileName = "\(arc4random()).\(fileType)"
        
        guard let data = Media else { return nil }
        self.data = data
    }
}

struct NetworkURL {
    let Url: String
    
    init(withService Service : String) {
        if BaseUrl == ""{
            assertionFailure("Base URL is Blank. Set in DGGlobalSharedVariable.swift")
        }
        self.Url = "\(BaseUrl)\(APIVersion)\(Service)"
    }
    
    init(withURL Url : String) {
        self.Url = Url
    }
}

enum NError : String, Error{
    case invalidMethod = "The Method You are using for the service is invalid."
    case PageNotFound = "The Service You are looking for is no longer available. 404"
    case ServerError = "The Server is not responding, Please try again after some time."
    case InvalidResponse = "Invalid Response From Server Try again."
    case NetworkError = "it looks like Your device is offline please make sure your internet connection is Stable."
    case BadUrl = "Please check the Service you are trying to request."
    case BadParams = "Please Check the parameters you are providing."
    case BadRequest = "Bad Reuest. Please try again. 400."
    case Forbidden = "You are not authorised for this request. 401"
    case DefError = "Please Check Source of App."
    case headerError = "Please provide valid headers."
    case BadAttachments = "Please Check the attachments you are providing"
    case ConversionError = "Your Request is successfull, but data conversion failed."
}

enum httpMethod : String{
    case get = "GET", post = "POST", delete = "DELETE", patch = "PATCH", put = "PUT", copy = "COPY", head = "HEAD", options = "OPTIONS", link = "LINK", unlink = "UNLINK", purge = "PURGE", lock = "LOCK", unlock = "UNLOCK", propfind = "PROPFIND", view = "VIEW"
}

class DGNetworkingServices {
    
    deinit {
        print("DGNetworkingServices Deinit")
        observation?.invalidate()
    }
    
    static let main = DGNetworkingServices()
    
    weak var delegate : DGNetworkingServicesDelegate? = nil
    
    private var observation: NSKeyValueObservation?
    
    
    /// This function will make an Network Api Request will return the response.
    /// # Functionalties:
    /// 1.  URL Configurable
    /// 2.  Header Specifications
    /// 3.  Response in Both Dictionary and Data
    /// 4.  More Specific Error
    /// - parameter Service : Serivce URL to call
    /// - parameter HttpMethod : HTTP method use for URL Request
    /// - parameter parameters : Parameters you wanted to pass with URL Request
    /// - parameter headers : Headers you wanted set for the URL request
    /// - parameter ResponseHandler : Response Handler with ResultType
    /// # Service:
    /// - Service is of `NetworkURL` which can be used as follows :
    /// -       NetworkURL(withURL: "https://www.google.com")
    /// -       NetworkURL(withService: "getEmployees")
    /// # ResponseHandler:
    /// - This Will Have two cases
    ///   - Success : if Request is successful
    ///       - returns response in:
    ///           - [String : Any]
    ///            - Data
    /// -       Response.0 /// for [String : Any]
    /// -       Response.1 /// for Data
    ///   - Faliure : if Request is successful
    ///       - returns Error in NSError
    /// -       Error.rawValue
    func MakeApiCall(Service : NetworkURL, HttpMethod : httpMethod, parameters : [String : Any]?, headers : [String : String]?,ResponseHandler: @escaping (Result<([String : Any],Data), NError>) -> Void){
        
        guard Reachability().isConnected() else {
            DispatchQueue.main.async {
                ResponseHandler(.failure(.NetworkError))
            }
            return
        }
        
        // Appending Your baseUrl and Version with Service
        let url = Service.Url
        
        // Comment Code if you don't want to print the url being called
        print(url)
        
        // Checking if url is valid or not
        
        if url.isValidURL{
            
            // checking if url string can convert to URLType or Not
            guard let URL = URL(string: url) else {
                DispatchQueue.main.async {
                    ResponseHandler(.failure(.BadUrl))
                }
                return
            }
            
            // init request object
            var request = URLRequest(url: URL)
            
            // check if parameters are provided
            if let JSONParameters = parameters{
                
                // convert json parameters to httpbody
                guard let httpBody = try? JSONSerialization.data(withJSONObject: JSONParameters, options: []) else {
                    DispatchQueue.main.async {
                        ResponseHandler(.failure(.BadParams))
                    }
                    return
                }
                // if httpbody conversion succesfull
                request.httpBody = httpBody
            }
            
            //headers
            request.httpMethod = HttpMethod.rawValue
            request.setValue("application/json", forHTTPHeaderField: "accept")
            request.setValue("application/json", forHTTPHeaderField: "content-type")
            
            if let header = headers{
                for (key,val) in  header{
                    request.setValue(val, forHTTPHeaderField: key)
                }
            }
            
            // session object init
            let session = URLSession.shared
            
            // calling the url
            let task = session.dataTask(with: request) { (Data, HTTPResponse, HTTPError) in
                // check if response is nil or not nil
                if let Response = HTTPResponse{
                    
                    // converting response to http response
                    let httpResponse = Response as? HTTPURLResponse
                    // status code switching
                    self.observation?.invalidate()
                    switch httpResponse?.statusCode {
                    case 200,201,202,203:
                        
                        guard let data = Data else {
                            DispatchQueue.main.async {
                                ResponseHandler(.failure(.InvalidResponse))
                            }
                            return
                        }
                        
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: [])
                            
                            if let JSONData = json as? [String: Any]{
                                DispatchQueue.main.async {
                                    ResponseHandler(.success((JSONData,data)))
                                }
                                
                            }else{
                                DispatchQueue.main.async {
                                    ResponseHandler(.failure(.InvalidResponse))
                                }
                            }
                        } catch  {
                            DispatchQueue.main.async {
                                ResponseHandler(.failure(.InvalidResponse))
                            }
                            
                        }
                    case 204:
                        
                        let output : [String : Any] = [
                            "status" : "201",
                            "message" : "Your input is accepted by the server you were requesting",
                            "meeageBy" : "DGNetworkingServices"
                        ]
                        
                        let dataOfString = "Your input is accepted by the server you were requesting".data(using: .utf16)
                        
                        if let data = dataOfString{
                            DispatchQueue.main.async {
                                
                                ResponseHandler(.success((output,data)))
                            }
                            
                        }else{
                            DispatchQueue.main.async {
                                
                                ResponseHandler(.failure(.ConversionError))
                            }
                        }
                        
                    case 400:
                        DispatchQueue.main.async {
                            ResponseHandler(.failure(.BadRequest))
                        }
                    case 401:
                        DispatchQueue.main.async {
                            ResponseHandler(.failure(.Forbidden))
                        }
                    case 403:
                        DispatchQueue.main.async {
                            ResponseHandler(.failure(.Forbidden))
                        }
                    case 404:
                        DispatchQueue.main.async {
                            ResponseHandler(.failure(.PageNotFound))
                        }
                    case 500:
                        DispatchQueue.main.async {
                            ResponseHandler(.failure(.ServerError))
                        }
                    default:
                        DispatchQueue.main.async {
                            ResponseHandler(.failure(.DefError))
                        }
                    }
                    
                }else{
                    if let httpError = HTTPError{
                        print(httpError.localizedDescription)
                        DispatchQueue.main.async {
                            ResponseHandler(.failure(.BadRequest))
                        }
                    }else{
                        DispatchQueue.main.async {
                            ResponseHandler(.failure(.InvalidResponse))
                        }
                    }
                }
                
            }
            
            observation = task.progress.observe(\.fractionCompleted) { (progress, _) in
                DispatchQueue.main.async {
                    self.delegate?.didProggressed(progress.fractionCompleted)
                }
            }
            
            task.resume()
            
        }else{
            DispatchQueue.main.async {
                ResponseHandler(.failure(.BadUrl))
            }
            
        }
        
        
    }
    
    /// This function will make an Network Api Request will return the response.
    /// # Functionalties:
    /// 1.  URL Configurable
    /// 2.  Header Specifications
    /// 3.  Response in Both Dictionary and Data
    /// 4.  More Specific Error
    /// - parameter Service : Serivce URL to call
    /// - parameter Attachments : Medias You wanted to upload
    /// - parameter HttpMethod : HTTP method use for URL Request
    /// - parameter parameters : Parameters you wanted to pass with URL Request
    /// - parameter headers : Headers you wanted set for the URL request
    /// - parameter ResponseHandler : Response Handler with ResultType
    /// # Service:
    /// - Service is of `NetworkURL` which can be used as follows :
    /// -       NetworkURL(withURL: "https://www.google.com")
    /// -       NetworkURL(withService: "getEmployees")
    /// # Attachments:
    /// - Create a Media object and pass it inside an array of Media
    /// # ResponseHandler:
    /// - This Will Have two cases
    ///   - Success : if Request is successful
    ///       - returns response in:
    ///           - [String : Any]
    ///            - Data
    /// -       Response.0 /// for [String : Any]
    /// -       Response.1 /// for Data
    ///   - Faliure : if Request is successful
    ///       - returns Error in NSError
    /// -       Error.rawValue
    func MakeApiCall(Service : NetworkURL, Attachments : [Media?]?, HttpMethod : httpMethod, parameters : [String : Any]?,ResponseHandler: @escaping (Result<([String : Any],Data), NError>) -> Void){
        
        guard Reachability().isConnected() else {
            DispatchQueue.main.async {
                ResponseHandler(.failure(.NetworkError))
            }
            return
        }
        
        // Appending Your baseUrl and Version with Service
        let url = Service.Url
        
        // Comment Code if you don't want to print the url being called
        print(url)
        
        // Checking if url is valid or not
        
        if url.isValidURL{
            
            // checking if url string can convert to URLType or Not
            guard let URL = URL(string: url) else {
                DispatchQueue.main.async {
                    
                    ResponseHandler(.failure(.BadUrl))
                }
                return
            }
            
            let boundary = generateBoundary()
            
            // init request object
            var request = URLRequest(url: URL)
            
            //headers
            request.httpMethod = HttpMethod.rawValue
            request.setValue("application/json", forHTTPHeaderField: "accept")
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "content-type")
            
            // body start
            if parameters != nil || Attachments != nil{
                
                let lineBreak = "\r\n"
                var body = Data()
                
                if let params = parameters {
                    for (key, value) in params {
                        body.append("--\(boundary + lineBreak)")
                        body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
                        body.append("\("\(value)" + lineBreak)")
                    }
                }
                
                if let Medias = Attachments{
                    for Media in Medias{
                        if let Att = Media{
                            body.append("--\(boundary + lineBreak)")
                            body.append("Content-Disposition: form-data; name=\"\(Att.key)\"; filename=\"\(Att.fileName)\"\(lineBreak)")
                            body.append("Content-Type: \(Att.mimeType + lineBreak + lineBreak)")
                            body.append(Att.data)
                            body.append(lineBreak)
                        }
                    }
                }
                
                body.append("--\(boundary)--\(lineBreak)")
                
                request.httpBody = body
            }
            // body end
            
            // session object init
            let session = URLSession.shared
            
            // calling the url
            let task = session.dataTask(with: request) { (Data, HTTPResponse, HTTPError) in
                // check if response is nil or not nil
                if let Response = HTTPResponse{
                    
                    // converting response to http response
                    let httpResponse = Response as? HTTPURLResponse
                    // status code switching
                    switch httpResponse?.statusCode {
                    case 200,201,202,203:
                        
                        guard let data = Data else {
                            DispatchQueue.main.async {
                                
                                ResponseHandler(.failure(.InvalidResponse))
                            }
                            return
                        }
                        
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: [])
                            
                            if let JSONData = json as? [String: Any]{
                                DispatchQueue.main.async {
                                    
                                    DispatchQueue.main.async {
                                        
                                        ResponseHandler(.success((JSONData,data)))
                                    }
                                    
                                }
                                
                            }else{
                                DispatchQueue.main.async {
                                    
                                    ResponseHandler(.failure(.InvalidResponse))
                                }
                            }
                        } catch  {
                            DispatchQueue.main.async {
                                
                                ResponseHandler(.failure(.InvalidResponse))
                            }
                            
                        }
                    case 204:
                        
                        let output : [String : Any] = [
                            "status" : "201",
                            "message" : "Your input is accepted by the server you were requesting",
                            "meeageBy" : "DGNetworkingServices"
                        ]
                        
                        let dataOfString = "Your input is accepted by the server you were requesting".data(using: .utf16)
                        
                        if let data = dataOfString{
                            DispatchQueue.main.async {
                                
                                
                                ResponseHandler(.success((output,data)))
                                
                            }
                            
                        }else{
                            DispatchQueue.main.async {
                                
                                ResponseHandler(.failure(.ConversionError))
                            }
                        }
                        
                    case 400:
                        DispatchQueue.main.async {
                            
                            ResponseHandler(.failure(.BadRequest))
                        }
                    case 401:
                        DispatchQueue.main.async {
                            
                            ResponseHandler(.failure(.Forbidden))
                        }
                    case 403:
                        DispatchQueue.main.async {
                            
                            ResponseHandler(.failure(.Forbidden))
                        }
                    case 404:
                        DispatchQueue.main.async {
                            
                            ResponseHandler(.failure(.PageNotFound))
                        }
                    case 500:
                        DispatchQueue.main.async {
                            
                            ResponseHandler(.failure(.ServerError))
                        }
                    default:
                        DispatchQueue.main.async {
                            
                            ResponseHandler(.failure(.DefError))
                        }
                    }
                    
                }else{
                    if let httpError = HTTPError{
                        print(httpError.localizedDescription)
                        DispatchQueue.main.async {
                            
                            ResponseHandler(.failure(.BadRequest))
                        }
                    }else{
                        DispatchQueue.main.async {
                            
                            ResponseHandler(.failure(.InvalidResponse))
                        }
                    }
                }
                
            }
            observation = task.progress.observe(\.fractionCompleted) { (progress, _) in
                DispatchQueue.main.async {
                    self.delegate?.didProggressed(progress.fractionCompleted)
                }
            }
            task.resume()
            
        }else{
            DispatchQueue.main.async {
                
                ResponseHandler(.failure(.BadUrl))
            }
            
        }
        
        
    }
    
    
    /// This function will download the file from the specified url and stores the file in device memory.
    /// - result have Following cases : true and false
    /// - Switch the Result and just fix the error which comes in the screen
    /// - Success : Api Call will return file location in device
    /// - Failures : Api Call will return error
    /// - parameter RemoteUrl : full length Static URL you wants to downloadFile
    /// - parameter fileName : name of the file
    /// - parameter Extension: file extension (e.g. pdf,docx,xlsx)
    func downloadFile(RemoteUrl : String, fileName : String, Extension : String,completion : @escaping (_ success : Bool,_ filelocation : URL?) -> Void){
        
        
        let itemUrl = URL(string: RemoteUrl)
        
        let documentDirectoruUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let destinationUrl = documentDirectoruUrl.appendingPathComponent("\(fileName).\(Extension)")
        
        if FileManager.default.fileExists(atPath: destinationUrl.path){
            debugPrint("The File Already Exist")
            completion(true, destinationUrl)
        }else{
            
            URLSession.shared.downloadTask(with: itemUrl!) { (url, response
            , error) in
                
                guard let tempLocation = url, error == nil else { return }
                
                do{
                    try FileManager.default.moveItem(at: tempLocation, to: destinationUrl)
                    completion(true, destinationUrl)
                } catch let error as NSError{
                    print(error.localizedDescription)
                    completion(false, nil)
                }
                
                
            }.resume()
            
        }
        
        
    }
    
    func toJSON(data : Data) -> [String : Any]?{
        
        do {
           let json = try JSONSerialization.jsonObject(with: data, options: [])
            
            if let JSONData = json as? [String: Any]{
                
                return JSONData
                
            }else{
                return nil
            }
        } catch  {
            
            return nil

        }
        
    }
    
    private func generateBoundary() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
}

extension String {
    var isValidURL: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            // it is a link, if the match covers the whole string
            return match.range.length == self.utf16.count
        } else {
            return false
        }
    }
}

public let ReachabilityStatusChangedNotification = "ReachabilityStatusChangedNotification"

public enum ReachabilityType: CustomStringConvertible {
    case WWAN
    case WiFi

    public var description: String {
        switch self {
        case .WWAN: return "WWAN"
        case .WiFi: return "WiFi"
        }
    }
}

public enum ReachabilityStatus: CustomStringConvertible  {
    case Offline
    case Online(ReachabilityType)
    case Unknown

    public var description: String {
        switch self {
        case .Offline: return "Offline"
        case .Online(let type): return "Online (\(type))"
        case .Unknown: return "Unknown"
        }
    }
}

public class Reachability {

    func connectionStatus() -> ReachabilityStatus {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)

        guard let defaultRouteReachability = (withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }) else {
           return .Unknown
        }

        var flags : SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return .Unknown
        }

        return ReachabilityStatus(reachabilityFlags: flags)
    }

    func monitorReachabilityChanges() {
        let host = "google.com"
        var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
        let reachability = SCNetworkReachabilityCreateWithName(nil, host)!

        SCNetworkReachabilitySetCallback(reachability, { (_, flags, _) in
            let status = ReachabilityStatus(reachabilityFlags: flags)

            NotificationCenter.default.post(name: NSNotification.Name(rawValue: ReachabilityStatusChangedNotification), object: nil, userInfo: ["Status": status.description])}, &context)

        SCNetworkReachabilityScheduleWithRunLoop(reachability, CFRunLoopGetMain(), CFRunLoopMode.commonModes.rawValue)
    }
    
    func isConnected() -> Bool{
        switch connectionStatus() {
        case .Offline:
            return false
        case .Online(_):
            return true
        case .Unknown:
            return false
        }
    }
}

extension ReachabilityStatus {

    public init(reachabilityFlags flags: SCNetworkReachabilityFlags) {
        let connectionRequired = flags.contains(.connectionRequired)
        let isReachable = flags.contains(.reachable)
        let isWWAN = flags.contains(.isWWAN)

        if !connectionRequired && isReachable {
            if isWWAN {
                self = .Online(.WWAN)
            } else {
                self = .Online(.WiFi)
            }
        } else {
            self =  .Offline
        }
    }
}
extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
