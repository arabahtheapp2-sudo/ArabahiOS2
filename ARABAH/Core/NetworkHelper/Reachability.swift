//
//  Reachability.swift
//  IDKanswers
//
//  Created by cql99 on 11/04/23.
//

import Foundation
import SystemConfiguration

public class Reachability {
    
    /**
     Checks whether the device currently has an active network connection.
     
     - Returns: `true` if the device is connected to the internet (via WiFi or Cellular), otherwise `false`.
     
     This method uses the SystemConfiguration framework to check the reachability of a zero-address (0.0.0.0),
     which represents the default route. It then checks network reachability flags to determine if the network
     is reachable without requiring an additional connection (like VPN or captive portal login).
     
     Notes:
     - The approach works for both WiFi and Cellular network connections.
     - If the reachability flags cannot be retrieved, the function returns `false`.
     */
    class func isConnectedToNetwork() -> Bool {
        
        // Create zero address (0.0.0.0) sockaddr_in struct
        var zeroAddress = sockaddr_in(
            sin_len: 0,
            sin_family: 0,
            sin_port: 0,
            sin_addr: in_addr(s_addr: 0),
            sin_zero: (0, 0, 0, 0, 0, 0, 0, 0)
        )
        
        // Set the length and family of the sockaddr_in struct
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        // Create a reachability reference to the zero address
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        // Prepare a variable to hold reachability flags
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        
        // Retrieve the flags; if failed, no network connection
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        /*
         The following commented code only works for WiFi connectivity:
         
         let isReachable = flags == .reachable
         let needsConnection = flags == .connectionRequired
         return isReachable && !needsConnection
         */
        
        // For both Cellular and WiFi connectivity:
        
        // Check if the network is reachable
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        
        // Check if a connection is required (e.g. VPN or login)
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        
        // Return true if reachable and no connection is required
        let ret = (isReachable && !needsConnection)
        
        return ret
    }
}
