//
//  DGNetworkingServices+Delegate.swift
//  DGNetworkingServices
//
//  Created by Dhruv Govani on 27/02/22.
//  Copyright © 2022 Dhruv Govani. All rights reserved.
//

import Foundation

/// This Delegate will be thrown for the every fraction in Double of every packet sent or received.
/// - can be easily used to show the proggress of long task
public protocol DGNetworkingServicesDelegate : AnyObject {
    func didProggressed(_ ProgressDone : Double)
}
