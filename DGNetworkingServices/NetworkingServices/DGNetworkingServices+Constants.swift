//
//  DGNetworkingServices+Constants.swift
//  DGNetworkingServices
//
//  Created by Dhruv Govani on 27/02/22.
//  Copyright © 2022 Dhruv Govani. All rights reserved.
//

import Foundation

/// Error Structure for the HTTP Error or any kind of Input error to let the Dev know what he did wrong.
public enum NError : String, Error{
    /// If you use a invalid Method to call the API
    /// # HTTP CODE : 405
    case invalidMethod = "The method you are using for the service is invalid."
    
    /// If you are calling an API which does not exist on the WWW
    /// # HTTP CODE : 404
    case PageNotFound = "The service You are looking for is no longer available."
    
    /// if your server encounters an internal error
    /// # HTTP CODE : 405
    case ServerError = "The server is not responding, Please try again after some time."
    
    /// if your server sends invalid type of response
    /// - occure when JSON decoding of the response fails
    case InvalidResponse = "Invalid JSON response received from server try again."
    
    /// if your device is currently offline
    case NetworkError = "it looks like your device is offline please make sure your internet connection is stable."
    
    /// if you are using an inavlid API URL
    /// - occurs when the url is incomplete or invalid in format
    case BadUrl = "Please check the service you are trying to request."
    
    /// if you are providing the bad type of a parameters
    /// - occurs when the provided parameters are not able to converted to the JSONBody
    case BadParams = "Please check the parameters you are providing."
    
    /// this error indicates that the server was unable to process the request sent by the client due to invalid syntax
    /// # HTTP CODE : 400
    case BadRequest = "Bad reuest. Please try again."
    
    /// if Server refuses the response because you are unauthorised to call
    /// # HTTP CODE : 401 , 403
    case Forbidden = "You are not authorised for this request."
    
    /// This Error Will Comes Up which is not catched in the program.
    /// # What to do:
    ///   - Check The API Params, Header, and Syntax you are usinf
    ///   - Check if API is working on the Postman
    ///   - Add Issue on the Github Repo with The request, params and header
    case DefError = "Uncaught exception. Please check source of enable logging to know more about the issue."
    
    /// This Error occours if you provide invalid headers in Request
    case headerError = "Please provide valid headers."
    
    /// This Error occours if you provide Invalid data for passing in media in Request
    case BadAttachments = "Please check the attachments you are providing."
    
    /// This Error occours if your server responds with the success but the data sent in response is not converted to JSON
    case ConversionError = "Your request is successfull, but data conversion failed."
    
    /// This Error occours if you will try to store a file in the location with the name already exist
    case FileAlreadyExist = "File already exist."
    
    /// This error will occour if access of the file from local location is Forbidden for the app
    case DocAccessError = "Document folder access forbidden"
    
    /// This error will occour if you are trying to access a file which does not exist
    case FileNotFound = "No data found on the directory you provided"
    
    /// This error will occour when decoding error comes
    case JSONDeocdingError = "Data could'nt be read. because it is in the incorrect format"
    
    case DecodingError = "The response couldn't be decoded to specified data format."
    
    case BadResponse = "The response returned is not in correct form."
}

/// HTTP Method which will be used to call the API
public enum httpMethod : String{
    case get = "GET", post = "POST", delete = "DELETE", patch = "PATCH", put = "PUT", copy = "COPY", head = "HEAD", options = "OPTIONS", link = "LINK", unlink = "UNLINK", purge = "PURGE", lock = "LOCK", unlock = "UNLOCK", propfind = "PROPFIND", view = "VIEW"
}
