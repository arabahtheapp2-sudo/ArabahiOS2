//
//  SocketConstants.swift
//
//  Copyright © 2021 Cqlsys MacBook Pro. All rights reserved.
//

import Foundation

/// Enum containing keys used throughout the socket communication
/// These include the base URL and various key strings used in socket events and payloads
enum SocketKeys: String {
    
    /// Base URL for the socket server connection
    case socketBaseUrl = "https://admin.arabahtheapp.com/"
    
    /// Key for user identifier used in socket payloads
    case userId = "UserId"
    
    /// Key for product identifier used in socket payloads
    case Productid = "Productid"
    
    /// Key for comment data sent through socket
    case comment = "comment"
    
    /// Returns the raw string value of the enum case
    var instance: String {
        return self.rawValue
    }
}

/// Enum representing the socket events that the client can emit/send to the server
enum SocketEmitters: String {
    
    /// Event name to notify server about user connection
    case connectUser = "connect_user"
    
    /// Event name for sending product comment data
    case Product_Comment = "Product_Comment"
    
    /// Returns the raw string value of the enum case
    var instance: String {
        return self.rawValue
    }
}

/// Enum representing the socket events that the client listens for from the server
enum SocketListeners: String {
    
    /// Event name for server acknowledgment of user connection
    case connectListener = "connect_user"
    
    /// Event name for receiving updated product comment lists
    case Product_Comment_list = "Product_Comment"
    
    /// Returns the raw string value of the enum case
    var instance: String {
        return self.rawValue
    }
}
