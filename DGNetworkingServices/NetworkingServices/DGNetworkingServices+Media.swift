//
//  DGNetworkingServices+Media.swift
//  DGNetworkingServices
//
//  Created by Dhruv Govani on 27/02/22.
//  Copyright © 2022 Dhruv Govani. All rights reserved.
//

import Foundation
import UIKit

/// Type of media used by the function to tell the system type of file being saved in camera roll.
public enum MediaType{
    case Photo, Video
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
