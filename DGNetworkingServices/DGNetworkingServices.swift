//
//  DGNetworkingServices.swift
//  DGNetworkingServices
//
//  Created by Dhruv Govani on 27/06/20.
//  Copyright © 2020 Dhruv Govani. All rights reserved.
//
/*
 
MIT License

Copyright (c) 2020 Dhruv Govani

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
 
*/

import Foundation
import UIKit
import Photos


/// # Functionalties:
/// 1.  URL Configurable
/// 2.  Easy Header, Parameters and Media Support
/// 3.  Response in Both Dictionary and Data
/// 4.  More Specific Error
/// 5. Logging for Better Debugging
/// 6. Observation of Call Proggress
/// 7. Easy To Use
/// 8. Other Useful Functionalities
/// 9. Simple Success and Failure Completion Handler
/// 10. Multilayer Validations
/// 11. Pure Swift and URLSession APIs
/// 12. No Third Party and Easy to Understand CodeBase
/// ### Many More Advanced Feature to come....
public class DGNetworkingServices {
    
    deinit {
        print("DGNetworkingServices Deinit")
        observation?.invalidate()
    }
    /// ADVANCE FEATURE UNDER CONSTRUCTION. WILL BE INCLUDED IN BETA 2
    /// - note : DO NOT MESS WITH THE STRUCT
    private struct RequestSettings {
        var timeoutInterval : TimeInterval?
        var cachePolicy : URLRequest.CachePolicy?
        var UseExpensiveNetwork : Bool?
        var MakeCallOnLowDataMode : Bool?
        var ServiceType : URLRequest.NetworkServiceType?
        var SessionConfig : URLSessionConfiguration?
    }
    
    public static let main = DGNetworkingServices()
    
    /// Set Delegate to self to get the Call Back for every fraction proggress made in the Call
    public weak var delegate : DGNetworkingServicesDelegate? = nil
    
    private var observation: NSKeyValueObservation?
    
    /// ADVANCE FEATURE UNDER CONSTRUCTION. WILL BE INCLUDED IN BETA 2
    /// - note : DO NOT MESS WITH THE VAR
    private var AdditionalRequestSettings : RequestSettings?
    
    private typealias Mimes = [String: String]
    
    /// This function will make an Network Api Request will return the response.
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
    ///   - Faliure : if Request is failed
    ///       - returns Error in NSError
    /// -       Error.rawValue
    /// # SEE DOCUMENTATION FOR MORE INFO
    public func MakeApiCall(Service : NetworkURL, HttpMethod : httpMethod, parameters : [String : Any]?, headers : [String : String]?,ResponseHandler: @escaping (Result<([String : Any],Data), NError>) -> Void){
        
        guard Reachability().isConnected() else {
            DispatchQueue.main.async {
                DGNetworkLogs.shared.setLog(url: Service.Url, statusCode: nil, parameters: parameters, headers: headers, response: nil, message: NError.NetworkError.rawValue, Method: HttpMethod.rawValue)
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
                    DGNetworkLogs.shared.setLog(url: url, statusCode: nil, parameters: parameters, headers: headers, response: nil, message: NError.BadUrl.rawValue, Method: HttpMethod.rawValue)
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
                        DGNetworkLogs.shared.setLog(url: url, statusCode: nil, parameters: parameters, headers: headers, response: nil, message: NError.BadParams.rawValue, Method: HttpMethod.rawValue)
                        ResponseHandler(.failure(.BadParams))
                    }
                    return
                }
                // if httpbody conversion succesfull
                request.httpBody = httpBody
            }
            
            //method
            request.httpMethod = HttpMethod.rawValue
            
            //header
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
                                DGNetworkLogs.shared.setLog(url: url, statusCode: httpResponse?.statusCode, parameters: parameters, headers: request.allHTTPHeaderFields, response: nil, message: NError.InvalidResponse.rawValue, Method: HttpMethod.rawValue)
                                ResponseHandler(.failure(.InvalidResponse))
                            }
                            return
                        }
                        
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: [])
                            
                            if let JSONData = json as? [String: Any]{
                                DispatchQueue.main.async {
                                    DGNetworkLogs.shared.setLog(url: url, statusCode: httpResponse?.statusCode, parameters: parameters, headers: request.allHTTPHeaderFields, response: JSONData, message: nil, Method: HttpMethod.rawValue)
                                    ResponseHandler(.success((JSONData,data)))
                                }
                                
                            }else{
                                DispatchQueue.main.async {
                                    DGNetworkLogs.shared.setLog(url: url, statusCode: httpResponse?.statusCode, parameters: parameters, headers: request.allHTTPHeaderFields, response: nil, message: NError.InvalidResponse.rawValue, Method: HttpMethod.rawValue)
                                    ResponseHandler(.failure(.InvalidResponse))
                                }
                            }
                        } catch  {
                            DispatchQueue.main.async {
                                DGNetworkLogs.shared.setLog(url: url, statusCode: httpResponse?.statusCode, parameters: parameters, headers: request.allHTTPHeaderFields, response: nil, message: NError.InvalidResponse.rawValue, Method: HttpMethod.rawValue)
                                ResponseHandler(.failure(.InvalidResponse))
                            }
                            
                        }
                    case 204:
                        
                        let output : [String : Any] = [
                            "status" : "201",
                            "message" : "Your input is accepted by the server you were requesting",
                            "MessageBy" : "DGNetworkingServices"
                        ]
                        
                        let dataOfString = "Your input is accepted by the server you were requesting".data(using: .utf16)
                        
                        if let data = dataOfString{
                            DispatchQueue.main.async {
                                DGNetworkLogs.shared.setLog(url: url, statusCode: httpResponse?.statusCode, parameters: parameters, headers: request.allHTTPHeaderFields, response: output, message: nil, Method: HttpMethod.rawValue)
                                ResponseHandler(.success((output,data)))
                            }
                            
                        }else{
                            DispatchQueue.main.async {
                                DGNetworkLogs.shared.setLog(url: url, statusCode: httpResponse?.statusCode, parameters: parameters, headers: request.allHTTPHeaderFields, response: nil, message: NError.ConversionError.rawValue, Method: HttpMethod.rawValue)
                                ResponseHandler(.failure(.ConversionError))
                            }
                        }
                        
                    case 400:
                        DispatchQueue.main.async {
                            DGNetworkLogs.shared.setLog(url: url, statusCode: httpResponse?.statusCode, parameters: parameters, headers: request.allHTTPHeaderFields, response: nil, message: NError.BadRequest.rawValue, Method: HttpMethod.rawValue)
                            ResponseHandler(.failure(.BadRequest))
                        }
                    case 401, 403:
                        DispatchQueue.main.async {
                             DGNetworkLogs.shared.setLog(url: url, statusCode: httpResponse?.statusCode, parameters: parameters, headers: request.allHTTPHeaderFields, response: nil, message: NError.Forbidden.rawValue, Method: HttpMethod.rawValue)
                            ResponseHandler(.failure(.Forbidden))
                        }
                    case 404:
                        DispatchQueue.main.async {
                             DGNetworkLogs.shared.setLog(url: url, statusCode: httpResponse?.statusCode, parameters: parameters, headers: request.allHTTPHeaderFields, response: nil, message: NError.PageNotFound.rawValue, Method: HttpMethod.rawValue)
                            ResponseHandler(.failure(.PageNotFound))
                        }
                    case 405:
                        DispatchQueue.main.async {
                             DGNetworkLogs.shared.setLog(url: url, statusCode: httpResponse?.statusCode, parameters: parameters, headers: request.allHTTPHeaderFields, response: nil, message: NError.invalidMethod.rawValue, Method: HttpMethod.rawValue)
                            ResponseHandler(.failure(.invalidMethod))
                        }
                    case 500:
                        DispatchQueue.main.async {
                             DGNetworkLogs.shared.setLog(url: url, statusCode: httpResponse?.statusCode, parameters: parameters, headers: request.allHTTPHeaderFields, response: nil, message: NError.ServerError.rawValue, Method: HttpMethod.rawValue)
                            ResponseHandler(.failure(.ServerError))
                        }
                    default:
                        DispatchQueue.main.async {
                             DGNetworkLogs.shared.setLog(url: url, statusCode: httpResponse?.statusCode, parameters: parameters, headers: request.allHTTPHeaderFields, response: nil, message: NError.DefError.rawValue, Method: HttpMethod.rawValue)
                            ResponseHandler(.failure(.DefError))
                        }
                    }
                    
                }else{
                    if let httpError = HTTPError{
                        print(httpError.localizedDescription)
                        DispatchQueue.main.async {
                             DGNetworkLogs.shared.setLog(url: url, statusCode: nil, parameters: parameters, headers: request.allHTTPHeaderFields, response: nil, message: NError.BadRequest.rawValue, Method: HttpMethod.rawValue)
                            ResponseHandler(.failure(.BadRequest))
                        }
                    }else{
                        DispatchQueue.main.async {
                            DGNetworkLogs.shared.setLog(url: url, statusCode: nil, parameters: parameters, headers: request.allHTTPHeaderFields, response: nil, message: NError.InvalidResponse.rawValue, Method: HttpMethod.rawValue)
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
                DGNetworkLogs.shared.setLog(url: url, statusCode: nil, parameters: parameters, headers: headers, response: nil, message: NError.BadUrl.rawValue, Method: HttpMethod.rawValue)
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
    /// - Create an Optional Media object and pass it inside an optionnal array of Media
    /// - Media and its Array has to be Optional to Avoid the crashes and other issues
    /// - See Documentation for More Details and USAGE
    /// # ResponseHandler:
    /// - This Will Have two cases
    ///   - Success : if Request is successful
    ///       - returns response in:
    ///           - [String : Any]
    ///            - Data
    /// -       Response.0 /// for [String : Any]
    /// -       Response.1 /// for Data
    ///   - Faliure : if Request is failed
    ///       - returns Error in NSError
    /// -       Error.rawValue
    public func MakeApiCall(Service : NetworkURL, Attachments : [Media?]?, HttpMethod : httpMethod, parameters : [String : Any]?,headers : [String : String]?,ResponseHandler: @escaping (Result<([String : Any],Data), NError>) -> Void){
        
        guard Reachability().isConnected() else {
            DispatchQueue.main.async {
                DGNetworkLogs.shared.setLog(url: Service.Url, statusCode: nil, parameters: parameters, headers: headers, response: nil, message: NError.NetworkError.rawValue, Method: HttpMethod.rawValue)
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
                    DGNetworkLogs.shared.setLog(url: url, statusCode: nil, parameters: parameters, headers: headers, response: nil, message: NError.BadUrl.rawValue, Method: HttpMethod.rawValue)
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
            
            if let header = headers{
                for (key,val) in  header{
                    request.setValue(val, forHTTPHeaderField: key)
                }
            }
            
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
                                DGNetworkLogs.shared.setLog(url: url, statusCode: httpResponse?.statusCode, parameters: parameters, headers: request.allHTTPHeaderFields, response: nil, message: NError.InvalidResponse.rawValue, Method: HttpMethod.rawValue)
                                ResponseHandler(.failure(.InvalidResponse))
                            }
                            return
                        }
                        
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: [])
                            
                            if let JSONData = json as? [String: Any]{
                                DispatchQueue.main.async {
                                    
                                    DispatchQueue.main.async {
                                        DGNetworkLogs.shared.setLog(url: url, statusCode: httpResponse?.statusCode, parameters: parameters, headers: request.allHTTPHeaderFields, response: JSONData, message: nil, Method: HttpMethod.rawValue)
                                        ResponseHandler(.success((JSONData,data)))
                                    }
                                    
                                }
                                
                            }else{
                                DispatchQueue.main.async {
                                    DGNetworkLogs.shared.setLog(url: url, statusCode: httpResponse?.statusCode, parameters: parameters, headers: request.allHTTPHeaderFields, response: nil, message: NError.InvalidResponse.rawValue, Method: HttpMethod.rawValue)
                                    ResponseHandler(.failure(.InvalidResponse))
                                }
                            }
                        } catch  {
                            DispatchQueue.main.async {
                                DGNetworkLogs.shared.setLog(url: url, statusCode: httpResponse?.statusCode, parameters: parameters, headers: request.allHTTPHeaderFields, response: nil, message: NError.InvalidResponse.rawValue, Method: HttpMethod.rawValue)
                                ResponseHandler(.failure(.InvalidResponse))
                            }
                            
                        }
                    case 204:
                        
                        let output : [String : Any] = [
                            "status" : "201",
                            "message" : "Your input is accepted by the server you were requesting",
                            "MessageBy" : "DGNetworkingServices"
                        ]
                        
                        let dataOfString = "Your input is accepted by the server you were requesting".data(using: .utf16)
                        
                        if let data = dataOfString{
                            DispatchQueue.main.async {
                                
                                DGNetworkLogs.shared.setLog(url: url, statusCode: httpResponse?.statusCode, parameters: parameters, headers: request.allHTTPHeaderFields, response: output, message: nil, Method: HttpMethod.rawValue)
                                ResponseHandler(.success((output,data)))
                                
                            }
                            
                        }else{
                            DispatchQueue.main.async {
                                DGNetworkLogs.shared.setLog(url: url, statusCode: httpResponse?.statusCode, parameters: parameters, headers: request.allHTTPHeaderFields, response: nil, message: NError.ConversionError.rawValue, Method: HttpMethod.rawValue)
                                ResponseHandler(.failure(.ConversionError))
                            }
                        }
                        
                    case 400:
                        DispatchQueue.main.async {
                            DGNetworkLogs.shared.setLog(url: url, statusCode: httpResponse?.statusCode, parameters: parameters, headers: request.allHTTPHeaderFields, response: nil, message: NError.BadRequest.rawValue, Method: HttpMethod.rawValue)
                            ResponseHandler(.failure(.BadRequest))
                        }
                    case 401, 403:
                        DispatchQueue.main.async {
                            DGNetworkLogs.shared.setLog(url: url, statusCode: httpResponse?.statusCode, parameters: parameters, headers: request.allHTTPHeaderFields, response: nil, message: NError.Forbidden.rawValue, Method: HttpMethod.rawValue)
                            ResponseHandler(.failure(.Forbidden))
                        }
                    case 404:
                        DispatchQueue.main.async {
                            DGNetworkLogs.shared.setLog(url: url, statusCode: httpResponse?.statusCode, parameters: parameters, headers: request.allHTTPHeaderFields, response: nil, message: NError.PageNotFound.rawValue, Method: HttpMethod.rawValue)
                            ResponseHandler(.failure(.PageNotFound))
                        }
                    case 405:
                        DispatchQueue.main.async {
                             DGNetworkLogs.shared.setLog(url: url, statusCode: httpResponse?.statusCode, parameters: parameters, headers: request.allHTTPHeaderFields, response: nil, message: NError.invalidMethod.rawValue, Method: HttpMethod.rawValue)
                            ResponseHandler(.failure(.invalidMethod))
                        }
                    case 500:
                        DispatchQueue.main.async {
                            DGNetworkLogs.shared.setLog(url: url, statusCode: httpResponse?.statusCode, parameters: parameters, headers: request.allHTTPHeaderFields, response: nil, message: NError.ServerError.rawValue, Method: HttpMethod.rawValue)
                            ResponseHandler(.failure(.ServerError))
                        }
                    default:
                        DispatchQueue.main.async {
                            DGNetworkLogs.shared.setLog(url: url, statusCode: httpResponse?.statusCode, parameters: parameters, headers: request.allHTTPHeaderFields, response: nil, message: NError.DefError.rawValue, Method: HttpMethod.rawValue)
                            ResponseHandler(.failure(.DefError))
                        }
                    }
                    
                }else{
                    if let httpError = HTTPError{
                        print(httpError.localizedDescription)
                        DispatchQueue.main.async {
                            DGNetworkLogs.shared.setLog(url: url, statusCode: nil, parameters: parameters, headers: request.allHTTPHeaderFields, response: nil, message: NError.BadRequest.rawValue, Method: HttpMethod.rawValue)
                            ResponseHandler(.failure(.BadRequest))
                        }
                    }else{
                        DispatchQueue.main.async {
                            DGNetworkLogs.shared.setLog(url: url, statusCode: nil, parameters: parameters, headers: request.allHTTPHeaderFields, response: nil, message: NError.InvalidResponse.rawValue, Method: HttpMethod.rawValue)
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
                DGNetworkLogs.shared.setLog(url: url, statusCode: nil, parameters: parameters, headers: headers, response: nil, message: NError.BadUrl.rawValue, Method: HttpMethod.rawValue)
                ResponseHandler(.failure(.BadUrl))
            }
            
        }
        
        
    }
    
    
    /// This function will make an Network Api Request to download the attached file to URL.
    /// - parameter Service : Serivce URL to download the file
    /// - parameter fileName : Name of file to use to store in the memory
    /// - parameter Extension : Extension of the file to store the file in certain type
    /// - parameter parameters : Parameters you wanted to pass with URL Request
    /// - parameter headers : Headers you wanted set for the Download request
    /// - parameter completion : Response Handler with ResultType
    /// # Service:
    /// - Service is of `NetworkURL` which can be used as follows :
    /// -       NetworkURL(withURL: "https://www.google.com")
    /// -       NetworkURL(withService: "getEmployees")
    /// # ResponseHandler:
    /// - This Will Have two cases
    ///   - Success : if download is successful
    ///       - returns Location URL of the downloaded file
    ///       - use the returned URL to Share or Save file in a permanant location
    ///   - Faliure : if Download fails
    ///       - returns Error in NSError
    /// -       Error.rawValue
    public func downloadFile(Service : NetworkURL, fileName : String, Extension : String, headers : [String : String]?,completion : @escaping (Result<URL, NError>) -> Void){
        
        guard Reachability().isConnected() else {
            DispatchQueue.main.async {
                DGNetworkLogs.shared.setLog(url: Service.Url, statusCode: nil, parameters: nil, headers: nil, response: nil, message: NError.NetworkError.rawValue, Method: "POST")
                completion(.failure(.NetworkError))
            }
            return
        }
        
        let url = Service.Url
        
        // Comment Code if you don't want to print the url being called
        print(url)
        
        guard let documentDirectoruUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else{
            completion(.failure(.DocAccessError))
            return
        }
        
        let destinationUrl = documentDirectoruUrl.appendingPathComponent("\(fileName).\(Extension)")
        
        if FileManager.default.fileExists(atPath: destinationUrl.path){
            
            completion(.success(destinationUrl))
            
        }else{
            
            guard url.isValidURL == true else {
                completion(.failure(.BadUrl))
                return
            }
            
            guard let DownloadURL = URL(string: url) else {
                DispatchQueue.main.async {
                    
                    completion(.failure(.BadUrl))
                }
                return
            }
            
            var Request = URLRequest(url: DownloadURL)
            
            if let header = headers{
                for (key,val) in  header{
                    Request.setValue(val, forHTTPHeaderField: key)
                }
            }
            
            let Session = URLSession.shared.downloadTask(with: Request) { (URL, HTTPResponse, Error) in
                if let Response = HTTPResponse{
                    
                    if let httpResponse = Response as? HTTPURLResponse{
                        
                        switch httpResponse.statusCode {
                        case 200,201,202,203:
                            guard let tempLocation = URL, Error == nil else {
                                print(Error ?? "")
                                DispatchQueue.main.async {
                                    completion(.failure(.DocAccessError))
                                }
                                return
                            }
                            
                            do{
                                try FileManager.default.moveItem(at: tempLocation, to: destinationUrl)
                                completion(.success(destinationUrl))
                            } catch let error as NSError{
                                print(error)
                                DispatchQueue.main.async {
                                    completion(.failure(.DocAccessError))
                                }
                            }
                            
                        case 400:
                            DispatchQueue.main.async {
                               // DGNetworkLogs.shared.setLog(url: url, statusCode: httpResponse?.statusCode, parameters: parameters, headers: request.allHTTPHeaderFields, response: nil, message: NError.BadRequest.rawValue, Method: HttpMethod.rawValue)
                                completion(.failure(.BadRequest))

                            }
                        case 401, 403:
                            DispatchQueue.main.async {
                              //  DGNetworkLogs.shared.setLog(url: url, statusCode: httpResponse?.statusCode, parameters: parameters, headers: request.allHTTPHeaderFields, response: nil, message: NError.Forbidden.rawValue, Method: HttpMethod.rawValue)
                                completion(.failure(.Forbidden))

                            }
                        case 404:
                            DispatchQueue.main.async {
                              //  DGNetworkLogs.shared.setLog(url: url, statusCode: httpResponse?.statusCode, parameters: parameters, headers: request.allHTTPHeaderFields, response: nil, message: NError.PageNotFound.rawValue, Method: HttpMethod.rawValue)
                                completion(.failure(.PageNotFound))
                            }
                        case 405:
                            DispatchQueue.main.async {
//                                 DGNetworkLogs.shared.setLog(url: url, statusCode: httpResponse?.statusCode, parameters: parameters, headers: request.allHTTPHeaderFields, response: nil, message: NError.invalidMethod.rawValue, Method: HttpMethod.rawValue)
                                completion(.failure(.invalidMethod))
                            }
                        case 500:
                            DispatchQueue.main.async {
                              //  DGNetworkLogs.shared.setLog(url: url, statusCode: httpResponse?.statusCode, parameters: parameters, headers: request.allHTTPHeaderFields, response: nil, message: NError.ServerError.rawValue, Method: HttpMethod.rawValue)
                                completion(.failure(.ServerError))
                            }
                        default:
                            completion(.failure(.DefError))
                        }
                    }else{
                        guard let tempLocation = URL, Error == nil else {
                            print(Error ?? "")
                            completion(.failure(.DocAccessError))
                            return
                        }
                        
                        do{
                            try FileManager.default.moveItem(at: tempLocation, to: destinationUrl)
                            completion(.success(destinationUrl))
                        } catch let error as NSError{
                            print(error)
                            completion(.failure(.DocAccessError))
                        }
                    }
                    
                }
            }
            
            observation = Session.progress.observe(\.fractionCompleted) { (progress, _) in
                DispatchQueue.main.async {
                    self.delegate?.didProggressed(progress.fractionCompleted)
                }
            }
            
            Session.resume()
            
        }
        
        
    }
    
    public func SaveFileToPhotos(fileUrl : URL, Type : MediaType, completion : @escaping ((Bool,Error?) -> ())){
        
        if PHPhotoLibrary.authorizationStatus() == .authorized{
            
            PHPhotoLibrary.shared().performChanges {
                if Type == .Photo{
                    PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: fileUrl)
                }else{
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileUrl)
                }
            } completionHandler: { (status, error) in
                completion(status,error)
            }
        }else{
            PHPhotoLibrary.requestAuthorization { (status) in
                if status == .authorized{
                    self.SaveFileToPhotos(fileUrl: fileUrl, Type: Type, completion: completion)
                }
            }
        }

    }

    /// This function will make an Network Api Request will return the response.
    /// - parameter Service : Serivce URL to download the file
    /// - parameter fileName : Name of file to use to store in the memory
    /// - parameter fileUrl : URL of the file to be upload
    /// - parameter parameters : Parameters you wanted to pass with Upload Request
    /// - parameter headers : Headers you wanted set for the Upload request
    /// - parameter ResponseHandler : Response Handler with ResultType
    /// # Service:
    /// - Service is of `NetworkURL` which can be used as follows :
    /// -       NetworkURL(withURL: "https://www.google.com")
    /// -       NetworkURL(withService: "getEmployees")
    /// # ResponseHandler:
    /// - This Will Have two cases
    ///   - Success : if upload Request is successful
    ///       - returns response in:
    ///           - [String : Any]
    ///            - Data
    /// -       Response.0 /// for [String : Any]
    /// -       Response.1 /// for Data
    ///   - Faliure : if Request is failed
    ///       - returns Error in NSError
    /// -       Error.rawValue
    /// # SEE DOCUMENTATION FOR MORE INFO
    public func UploadFile(Service : NetworkURL, HttpMethod : httpMethod, fileUrl : URL,parameters : [String : Any]?, headers : [String : String]?,ResponseHandler: @escaping (Result<([String : Any],Data), NError>) -> Void){
        
        guard Reachability().isConnected() else {
            DispatchQueue.main.async {
                DGNetworkLogs.shared.setLog(url: Service.Url, statusCode: nil, parameters: parameters, headers: headers, response: nil, message: NError.NetworkError.rawValue, Method: HttpMethod.rawValue)
                ResponseHandler(.failure(.NetworkError))
            }
            return
        }
        
        // Appending Your baseUrl and Version with Service
        let url = Service.Url
        
        // Comment Code if you don't want to print the url being called
        print(url)
        
        if url.isValidURL{
            
            guard let URL = URL(string: url) else {
                DispatchQueue.main.async {
                    DGNetworkLogs.shared.setLog(url: url, statusCode: nil, parameters: parameters, headers: headers, response: nil, message: NError.BadUrl.rawValue, Method: HttpMethod.rawValue)
                    ResponseHandler(.failure(.BadUrl))
                }
                return
            }
            
            
            do{
                let fileData = try Data(contentsOf: fileUrl)
                
                var request = URLRequest(url: URL)
                
                request.httpMethod = HttpMethod.rawValue
                
                let boundary = generateBoundary()
                
                request.setValue("application/json", forHTTPHeaderField: "accept")
                request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "content-type")
                
                if let header = headers{
                    for (key,val) in  header{
                        request.setValue(val, forHTTPHeaderField: key)
                    }
                }
                
                let sessionConfig = URLSessionConfiguration.background(withIdentifier: url)
                
                sessionConfig.isDiscretionary = true
                sessionConfig.timeoutIntervalForRequest = 600
                
                let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: .main)
                
                if let JSONParameters = parameters{
                    
                    // convert json parameters to httpbody
                    guard let httpBody = try? JSONSerialization.data(withJSONObject: JSONParameters, options: []) else {
                        DispatchQueue.main.async {
                            DGNetworkLogs.shared.setLog(url: url, statusCode: nil, parameters: parameters, headers: headers, response: nil, message: NError.BadParams.rawValue, Method: HttpMethod.rawValue)
                            ResponseHandler(.failure(.BadParams))
                        }
                        return
                    }
                    // if httpbody conversion succesfull
                    request.httpBody = httpBody
                }
                
                let task = session.uploadTask(with: request, from: fileData) { (Data, HTTPResponse, HTTPError) in
                    
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
                                    DGNetworkLogs.shared.setLog(url: url, statusCode: httpResponse?.statusCode, parameters: parameters, headers: request.allHTTPHeaderFields, response: nil, message: NError.InvalidResponse.rawValue, Method: HttpMethod.rawValue)
                                    ResponseHandler(.failure(.InvalidResponse))
                                }
                                return
                            }
                            
                            do {
                                let json = try JSONSerialization.jsonObject(with: data, options: [])
                                
                                if let JSONData = json as? [String: Any]{
                                    DispatchQueue.main.async {
                                        DGNetworkLogs.shared.setLog(url: url, statusCode: httpResponse?.statusCode, parameters: parameters, headers: request.allHTTPHeaderFields, response: JSONData, message: nil, Method: HttpMethod.rawValue)
                                        ResponseHandler(.success((JSONData,data)))
                                    }
                                    
                                }else{
                                    DispatchQueue.main.async {
                                        DGNetworkLogs.shared.setLog(url: url, statusCode: httpResponse?.statusCode, parameters: parameters, headers: request.allHTTPHeaderFields, response: nil, message: NError.InvalidResponse.rawValue, Method: HttpMethod.rawValue)
                                        ResponseHandler(.failure(.InvalidResponse))
                                    }
                                }
                            } catch  {
                                DispatchQueue.main.async {
                                    DGNetworkLogs.shared.setLog(url: url, statusCode: httpResponse?.statusCode, parameters: parameters, headers: request.allHTTPHeaderFields, response: nil, message: NError.InvalidResponse.rawValue, Method: HttpMethod.rawValue)
                                    ResponseHandler(.failure(.InvalidResponse))
                                }
                                
                            }
                        case 204:
                            
                            let output : [String : Any] = [
                                "status" : "201",
                                "message" : "Your input is accepted by the server you were requesting",
                                "MessageBy" : "DGNetworkingServices"
                            ]
                            
                            let dataOfString = "Your input is accepted by the server you were requesting".data(using: .utf16)
                            
                            if let data = dataOfString{
                                DispatchQueue.main.async {
                                    DGNetworkLogs.shared.setLog(url: url, statusCode: httpResponse?.statusCode, parameters: parameters, headers: request.allHTTPHeaderFields, response: output, message: nil, Method: HttpMethod.rawValue)
                                    ResponseHandler(.success((output,data)))
                                }
                                
                            }else{
                                DispatchQueue.main.async {
                                    DGNetworkLogs.shared.setLog(url: url, statusCode: httpResponse?.statusCode, parameters: parameters, headers: request.allHTTPHeaderFields, response: nil, message: NError.ConversionError.rawValue, Method: HttpMethod.rawValue)
                                    ResponseHandler(.failure(.ConversionError))
                                }
                            }
                            
                        case 400:
                            DispatchQueue.main.async {
                                DGNetworkLogs.shared.setLog(url: url, statusCode: httpResponse?.statusCode, parameters: parameters, headers: request.allHTTPHeaderFields, response: nil, message: NError.BadRequest.rawValue, Method: HttpMethod.rawValue)
                                ResponseHandler(.failure(.BadRequest))
                            }
                        case 401, 403:
                            DispatchQueue.main.async {
                                 DGNetworkLogs.shared.setLog(url: url, statusCode: httpResponse?.statusCode, parameters: parameters, headers: request.allHTTPHeaderFields, response: nil, message: NError.Forbidden.rawValue, Method: HttpMethod.rawValue)
                                ResponseHandler(.failure(.Forbidden))
                            }
                        case 404:
                            DispatchQueue.main.async {
                                 DGNetworkLogs.shared.setLog(url: url, statusCode: httpResponse?.statusCode, parameters: parameters, headers: request.allHTTPHeaderFields, response: nil, message: NError.PageNotFound.rawValue, Method: HttpMethod.rawValue)
                                ResponseHandler(.failure(.PageNotFound))
                            }
                        case 405:
                            DispatchQueue.main.async {
                                 DGNetworkLogs.shared.setLog(url: url, statusCode: httpResponse?.statusCode, parameters: parameters, headers: request.allHTTPHeaderFields, response: nil, message: NError.invalidMethod.rawValue, Method: HttpMethod.rawValue)
                                ResponseHandler(.failure(.invalidMethod))
                            }
                        case 500:
                            DispatchQueue.main.async {
                                 DGNetworkLogs.shared.setLog(url: url, statusCode: httpResponse?.statusCode, parameters: parameters, headers: request.allHTTPHeaderFields, response: nil, message: NError.ServerError.rawValue, Method: HttpMethod.rawValue)
                                ResponseHandler(.failure(.ServerError))
                            }
                        default:
                            DispatchQueue.main.async {
                                 DGNetworkLogs.shared.setLog(url: url, statusCode: httpResponse?.statusCode, parameters: parameters, headers: request.allHTTPHeaderFields, response: nil, message: NError.DefError.rawValue, Method: HttpMethod.rawValue)
                                ResponseHandler(.failure(.DefError))
                            }
                        }
                        
                    }else{
                        if let httpError = HTTPError{
                            print(httpError.localizedDescription)
                            DispatchQueue.main.async {
                                 DGNetworkLogs.shared.setLog(url: url, statusCode: nil, parameters: parameters, headers: request.allHTTPHeaderFields, response: nil, message: NError.BadRequest.rawValue, Method: HttpMethod.rawValue)
                                ResponseHandler(.failure(.BadRequest))
                            }
                        }else{
                            DispatchQueue.main.async {
                                DGNetworkLogs.shared.setLog(url: url, statusCode: nil, parameters: parameters, headers: request.allHTTPHeaderFields, response: nil, message: NError.InvalidResponse.rawValue, Method: HttpMethod.rawValue)
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
                
                
            }catch{
                print(error)
                ResponseHandler(.failure(.DocAccessError))
            }
            
        }else{
            DispatchQueue.main.async {
                DGNetworkLogs.shared.setLog(url: url, statusCode: nil, parameters: parameters, headers: headers, response: nil, message: NError.BadUrl.rawValue, Method: HttpMethod.rawValue)
                ResponseHandler(.failure(.BadUrl))
            }
        }
    }
    
    /// This Function will convert the Data to Dictionary
    /// - parameter data : Response data you wanted to convert in [String : Any]
    /// - function will return nil if conversion fails
    public func toJSON(data : Data) -> [String : Any]?{
        
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
    
    /// This function will return MimeType for the Specified extension
    /// - parameter FileExtension : File Extension whos MimeType You wanted
    public func GetMimeType(FileExtension : String) -> String?{
        if let path = Bundle.main.path(forResource: "mime", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONDecoder().decode(Mimes.self, from: data)
                
                if let mime = jsonResult[FileExtension]{
                    return mime
                }else{
                    return nil
                }
                
            } catch {
                print(error)
                return nil
            }
        }else{
            print("path not found")
            return nil
        }
    }
    
}
