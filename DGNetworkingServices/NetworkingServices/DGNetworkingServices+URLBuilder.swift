//
//  DGNetworkingServices+URLBuilder.swift
//  DGNetworkingServices
//
//  Created by Dhruv Govani on 27/02/22.
//  Copyright © 2022 Dhruv Govani. All rights reserved.
//

import Foundation

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
