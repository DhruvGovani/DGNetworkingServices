//
//  Constants.swift
//  DGNetworkingServices
//
//  Created by Dhruv Govani on 24/10/20.
//  Copyright © 2020 Dhruv Govani. All rights reserved.
//

import Foundation
import UIKit

/// This Delegate will be thrown for the every fraction in Double of every packet sent or received.
/// - can be easily used to show the proggress of long task
public protocol DGNetworkingServicesDelegate : AnyObject {
    func didProggressed(_ ProgressDone : Double)
}

///Compression Quality For JPEG Image you wanted to upload
/// # CGFloats According to Cases
/// -  lowest  = 0
/// -  low     = 0.25
/// -  medium  = 0.5
/// -  high    = 0.75
/// -  highest = 1
public enum JPEGQuality: CGFloat {
    case lowest  = 0
    case low     = 0.25
    case medium  = 0.5
    case high    = 0.75
    case highest = 1
}

/// A Structure of Request Logging configurations
public struct Log {
    /// Set Request as True to Log Requests
    var request : Bool
    /// Set Response as True to Log Response
    var response : Bool
    
    /// Modify the Logging settings
    /// - parameter logRequest: Set as True to Log Requests
    /// - parameter logResponse: Set as True to Log Response
    public init(logRequest : Bool, logResponse : Bool) {
        self.request = logRequest
        self.response = logResponse
    }
}

/// Media Structure will take care of the data extraction of JPEG and PNG images you provide. and you can also provide custom data and mimeTypes
/// # Key : Key is the parameter of the API  where the media will be passed as Value
/// # fileName : FileName is the name of file which will be assigned as single random word by arc4random
/// # data :  data of media or a file being uploaded or passed to ther server
/// # mimeType : mimeType indicates the type of your file, eg. image, video, pdf,
/// - Leave Mime type as nil to autoFetch the mimtype from the fileType
public struct Media {
    let key: String
    let fileName: String
    let data: Data
    let mimeType: String
    
    /// Create a Media? for the JPEG Image Uploading
    /// - parameter JpegImage : UIImage you wanted to upload
    /// - parameter key : parameter key where the image will be passed
    /// - parameter compression: compression of the image being passed
    public init?(withJPEGImage JpegImage: UIImage, forKey key: String, compression : JPEGQuality) {
        self.key = key
        self.mimeType = "image/jpg"
        self.fileName = "\(arc4random()).jpeg"
        
        guard let data = JpegImage.jpegData(compressionQuality: compression.rawValue) else { return nil }
        self.data = data
    }
    
    /// Create a Media? for the PNG Image Uploading
    /// - parameter pngImage : UIImage you wanted to upload
    /// - parameter key : parameter key where the image will be passed
    public init?(withPNGImage pngImage: UIImage, forKey key: String) {
        self.key = key
        self.mimeType = "image/png"
        self.fileName = "\(arc4random()).png"
        
        guard let data = pngImage.pngData() else { return nil }
        self.data = data
    }
    
    /// Create a Media out of a file from the given URL for Uploading
    /// - parameter fileUrl : URL location of the file
    /// - parameter fileExtension : Type of the file being uploaded. Extension of the file Only.
    /// - parameter mimeType : mimeType of the file. Leave Nil for autoFetch from fileExtension
    /// - parameter key : parameter key where the file will be passed
    public init?(withFileFrom fileUrl : URL, fileExtension: String, mimeType : String?, key: String) {
        self.key = key
        
        if let mime = mimeType{
            self.mimeType = mime
        }else{
            if let autoMime = DGNetworkingServices.main.GetMimeType(FileExtension: fileExtension){
                self.mimeType = autoMime
            }else{
                self.mimeType = "___INVALID AUTO MIMETYPE___"
                assertionFailure("Auto mimeType fetch error! please enter valid fileType or provide the mimeType manually")
            }
        }
        
        self.fileName = "\(arc4random()).\(fileExtension)"
        
        do{
            let FetchedData = try Data(contentsOf: fileUrl)
            
            self.data = FetchedData
            
        }catch{
            print(error)
            assertionFailure("error while getting data from the url")
            return nil
        }
        
    }
    
    /// Create a Media out of a file from the given URL for Uploading
    /// - parameter FileData : data you wanted to upload
    /// - parameter fileExtension : Type of the file being uploaded. Extension of the file Only.
    /// - parameter mimeType : mimeType of the data. Leave Nil for autoFetch from fileExtension
    /// - parameter key : parameter key where the file will be passed
    public init?(key : String, FileData : Data?, mimeType : String?, fileExtension : String){
        self.key = key
        if let mime = mimeType{
            self.mimeType = mime
        }else{
            if let autoMime = DGNetworkingServices.main.GetMimeType(FileExtension: fileExtension){
                self.mimeType = autoMime
            }else{
                self.mimeType = "___INVALID AUTO MIMETYPE___"
                assertionFailure("Auto mimeType fetch error! please enter valid fileType or provide the mimeType Manually")
            }
        }
        self.fileName = "\(arc4random()).\(fileExtension)"
        
        guard let data = FileData else { return nil }
        self.data = data
    }
}

/// NetworkURL Structure is Very easy to use multipurpose structure for the API URLs.
/// - NetworkURL Structure helps the program to easily implement the correct url for the integrity and error handlings
/// - NetworkURL makes Sure that if the doman changes all you have to do is change the BaseUrl from DGGlobalSharedVariable and KaBoom magic Happend
/// - NetworkURL Makes sure that you can use the static apis which is out side of your server enviournement and baseURL.
public struct NetworkURL {
    let Url: String
    
    /// Init API URL with a ServiceName which will be appended to BaseUrl and APIVersion specified in DGGlobalSharedVariable.swift
    /// # How it works :
    ///   - for example BaseUrl is set as : BaseUrl = "www.google.com"
    ///   - and APIVersion is : APIVersion =  "/api/v1/"
    ///   - and Service parameter is "GetUserData"
    ///   - API Going to be called will be "www.google.com/api/v1/GetUserData"
    /// - See ExapleViewController.swift for more info.
    /// - parameter Service : Service from Your BaseURL you would Like to call
    public init(withService Service : String) {
        if DGNetworkingServiceBaseUrl == ""{
            assertionFailure("Base URL is blank. Please Set DGNetworkingServiceBaseUrl")
        }
        self.Url = "\(DGNetworkingServiceBaseUrl)\(DGNetworkingServiceAPIVersion)\(Service)"
    }
    
    /// This function will create a API request from the static URL you provided
    /// - parameter Url : Full URL of the API in string you wanted to call
    public init(withURL Url : String) {
        self.Url = Url
    }
}


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

/// Type of media used by the function to tell the system type of file being saved in camera roll.
public enum MediaType{
    case Photo, Video
}
