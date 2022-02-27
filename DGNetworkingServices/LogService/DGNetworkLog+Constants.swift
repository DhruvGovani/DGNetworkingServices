//
//  Constants.swift
//  DGNetworkingServices
//
//  Created by Dhruv Govani on 24/10/20.
//  Copyright © 2020 Dhruv Govani. All rights reserved.
//

import Foundation
import UIKit

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
