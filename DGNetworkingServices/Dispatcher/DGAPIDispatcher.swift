//
//  DGAPIDispatcher.swift
//  DGNetworkingServices
//
//  Created by Dhruv Govani on 22/02/22.
//  Copyright © 2022 Dhruv Govani. All rights reserved.
//

import Foundation

/// Request Status indicates the current status of the Request
public enum DispatchRequestStatus{
    case Dispatched
    case Running
    case Finished
}

/// Model used to create the request object to dispatch in dispatcher
public struct DispatchRequest : Identifiable{
    public var id = UUID()
    public var Service : NetworkURL
    public var HttpMethod : httpMethod
    public var parameters : [String : Any]?
    public var headers : [String : String]?
    public var medias : [Media?]?
    public var responseModel : Codable? = nil
    var status : DispatchRequestStatus = .Dispatched
    var createdAt : Date
    var updatedAt : Date
    
    /// This function will make an Dispatchable Network Api Request
    /// - parameter Service : Serivce URL to call
    /// - parameter HttpMethod : HTTP method use for URL Request
    /// - parameter parameters : Parameters you wanted to pass with URL Request
    /// - parameter headers : Headers you wanted set for the URL request
    /// - parameter responseModel : model to use for decoding of the response
    public init(
        Service : NetworkURL,
        HttpMethod : httpMethod,
        parameters : [String : Any]?,
        headers : [String : String]?,
        medias : [Media?]? = nil,
        responseModel : Codable? = nil
    ){
        
        self.Service = Service
        self.HttpMethod = HttpMethod
        self.parameters = parameters
        self.headers = headers
        self.medias = medias
        self.status = .Dispatched
        self.createdAt = Date()
        self.updatedAt = Date()
        self.responseModel = responseModel
        
    }
    
    ///This function will help to change the status of dispatched request
    mutating func changeStatusTo(_ newStatus : DispatchRequestStatus){
        self.status = newStatus
        self.updatedAt = Date()
    }
    
}

///Model to return with request and response of the dispatched requests
public struct DispatchResult{
    public var id : UUID
    public var request : DispatchRequest
    public var result : Result<([String : Any],Data), NError>
}

public protocol DGAPIDispatcherDelegate : NSObject {
    ///Will get Called every time a single request is completed
    func requestDidCompleted(_ dispatcher : DGAPIDispatcher, completedApi : DispatchResult)
    ///Will get called every time all the requests are completed
    func dispatchedAPIsDidComplete(_ dispatcher : DGAPIDispatcher, completedApis : [DispatchResult])
}

public class DGAPIDispatcher {
    
    private init(){}
    
    ///Shared object of the class to access it's functions and properties
    public static let main = DGAPIDispatcher()
    
    ///All the apis which are dispatched
    private var dispatchedAPIs : [DispatchRequest] = []
    
    ///All the dispatched apis which are completed
    private var completedAPIs : [DispatchResult] = []
    
    private let group = DispatchGroup()
    
    public weak var delegate : DGAPIDispatcherDelegate? = nil
    
    public var autoClearOnEachCompletion : Bool = false
    
    ///Dispatch a new api into the dispatch api group
    public func dispatchNewApi(_ request : DispatchRequest) -> UUID{
        dispatchedAPIs.append(request)
        return request.id
    }
    
    ///Get all pending request from the current dispatch api group
    public func getAllPendingRequests() -> [DispatchRequest]{
        
        return dispatchedAPIs.filter { (req) -> Bool in
            return req.status == .Dispatched
        }
        
    }
    
    ///Get all completed apis from the current dispatch api group
    public func getCompletedApis() -> [DispatchResult]{
        
        return completedAPIs
       
    }
    
    ///clear all dispatch api groups
    public func clearAll(){
        self.completedAPIs.removeAll()
        self.dispatchedAPIs.removeAll()
    }
    
    ///method will run all the dispatched apis and return with the result of it once all the apis are completed
    public func runDispatchedAPIs(_ completion : @escaping (([DispatchResult]) -> ())){
        
        for dispatchedAPIindex in 0..<dispatchedAPIs.count{
            
            let dispatchedAPI = dispatchedAPIs[dispatchedAPIindex]
            
            group.enter() //Entering the Group
            
            self.dispatchedAPIs[dispatchedAPIindex].changeStatusTo(.Running)

            DGNetworkingServices.main.MakeApiCall(Service: dispatchedAPI.Service, Attachments: dispatchedAPI.medias, HttpMethod: dispatchedAPI.HttpMethod, parameters: dispatchedAPI.parameters, headers: dispatchedAPI.headers) { (Result) in
                
                let dispatchApiResult = DispatchResult(id: dispatchedAPI.id, request: dispatchedAPI, result: Result)
                
                self.dispatchedAPIs[dispatchedAPIindex].changeStatusTo(.Finished)
                
                self.completedAPIs.append(dispatchApiResult)
                
                self.group.leave() //Exiting the group
                
                self.delegate?.requestDidCompleted(self, completedApi: dispatchApiResult) //Tells the class that single api is completed
                
            }
            
            
        }
                
        //Once all the apis are exited the group notify and return completion and delegate to confromer class
        group.notify(queue: .main) {
            
            self.dispatchedAPIs.removeAll()
            self.delegate?.dispatchedAPIsDidComplete(self, completedApis: self.completedAPIs)
            completion(self.completedAPIs)
            if self.autoClearOnEachCompletion{
                self.clearAll()
            }
            
        }
        
    }
    
}
