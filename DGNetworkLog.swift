//
//  DGNetworkLog.swift
//  DGNetworkingServices
//
//  Created by Dhruv Govani on 24/10/20.
//  Copyright © 2020 Dhruv Govani. All rights reserved.
//

import Foundation

/// DGNetworkLogs is Structurized  in a way to provide you as much as information about the API Called which helps you to debug the api requests and responses
/// # Features :
/// - Log The Request and Response and Get a print of it to know what happened inside
/// - Logs will be destroyed when app crashes or launched again
/// - Logs are not beign store in user defaults or anywhere in file in device to make it secure and only a Session only thing
/// - Fully Configurable
/// - Filter by Requests and Status Code
public class DGNetworkLogs {
    
    public struct DGLog{
        var url : String?
        var time : Date?
        var statusCode : Int?
        var parameters : [String : Any]?
        var headers : [String : String]?
        var response : [String : Any]?
        var message : String?
        var httpMethod : String
    }
    /// Shared Object to access the Functions of DGNetworkLogs
    public static let shared = DGNetworkLogs()
    
    private var Logs = [DGLog]()
    
    /// This Variable Defines the Logging of request after it's Reconfiguration
    public var logging : Log = Log(logRequest: false, logResponse: false)
    
    /// This Function will be used in main codeBase to Log the Requests and Responses
    /// # WARNING : DO NOT MESS WITH THIS FUCNTION ONLY MADE TO BE USED IN THE MAIN CODEBASE
    public func setLog(url : String?, statusCode : Int?, parameters : [String:Any]?, headers : [String:String]?, response : [String:Any]?, message : String?, Method : String) {
        
        if logging.request == true{
            if logging.response == true{
                Logs.append(DGLog(url: url, time: Date(), statusCode: statusCode, parameters: parameters, headers: headers, response: response, message: message, httpMethod: Method))
            }else{
                Logs.append(DGLog(url: url, time: Date(), statusCode: statusCode, parameters: parameters, headers: headers, response: nil, message: message, httpMethod: Method))
            }
        }
        
    }
    
    /// This Function Will print all the logged Requests and Responses
    /// - parameter filterByUrl : provide a url string to filter the result by the url
    /// - parameter filterByStatusCode : provide a HTTP Status code  to filter the result by the HTTP Status Code
    public func PrintNetworkLogs(filterByUrl : String?, filterByStatusCode : Int?){
        
        if Logs.count <= 0{
            return
        }
        
        var logtoReturn = [DGLog]()
        
        if filterByUrl != nil && filterByStatusCode != nil{
            
            if let furl = filterByUrl{
                for L in 0...Logs.count - 1{
                    if Logs[L].url == furl{
                        logtoReturn.append(Logs[L])
                    }
                }
            }
            
            if let fStatsus = filterByStatusCode{
                for L in 0...Logs.count - 1{
                    if Logs[L].statusCode == fStatsus{
                        logtoReturn.append(Logs[L])
                    }
                }
            }
            
        }else{
            for L in 0...Logs.count - 1{
                
                logtoReturn.append(Logs[L])
                
            }
        }
        print("--------NETWORK LOG(S)----------")
        for L in 0...logtoReturn.count - 1{
            
            let Log = logtoReturn[L]
            print("\nLog ID : \(L+1)")
            print("URL : \(Log.url ?? "not found")")
            print("Method : \(Log.httpMethod)")
            print("statusCode : \(String(Log.statusCode ?? 0))")
            if Log.parameters != nil{
                print("Parameters : \(Log.parameters!)")
            }
            if Log.headers != nil{
                print("Headers : \(Log.headers!)")
            }
            if Log.response != nil{
                print("Response : \(Log.response!)")
            }
            if Log.message != nil{
                print("Message : \(Log.message!)")
            }
            if Log.time != nil{
                print("Log Time : \(Log.time!)")
            }
        }

        print("\n--------NETWORK LOG(S)----------")
        print("\nto Stop this from prinitng Set DGNetworkLogs.shared.logging.request / response to false")

    }
}
