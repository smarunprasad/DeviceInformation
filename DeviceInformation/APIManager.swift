//
//  APIManager.swift
//  DeviceInformation
//
//  Created by Arunprasat Selvaraj on 25/06/2019.
//  Copyright © 2019 Arunprasat Selvaraj. All rights reserved.
//

import Foundation
import SystemConfiguration

final class APIManager {
        
    static func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        if flags.isEmpty {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
    
    static func dataRequest(request: URLRequest, completionHandler:@escaping ((Data) -> Void), errorHandler:@escaping ((Error?) -> Void)) {
        
        // API call using dataTask
        let dataTask = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            //Passing the (data, response, error) to completionHandler
            
            if error == nil {
                guard let newData = data else {
                    return
                }
                completionHandler(newData)
            }
            else {
                errorHandler(error)
            }
        }
        dataTask.resume()
    }
}
