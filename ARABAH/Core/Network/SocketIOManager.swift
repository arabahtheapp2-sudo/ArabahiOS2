//
//  SocketsManager.swift
//  Service Near
//
//  Created by cqlnp on 06/05/24.
//

//
//  SocketIOManager.swift
//  Service Near
//
//  Created by cqlnp on 06/05/24.
//

import Foundation
import SocketIO
import SwiftyJSON

protocol SocketDelegate: AnyObject {
    func listenedData(data: JSON, response: String)
}

class SocketIOManager: NSObject {
    
    static let sharedInstance = SocketIOManager()
      
      private lazy var manager: SocketManager? = {
          guard let url = URL(string: AppConstants.imageURL) else {
             // Invalid Socket URL
              return nil
          }
          return SocketManager(socketURL: url,
                               config: [
                                  .compress,
                                  .log(true),
                                  .reconnects(true),
                                  .reconnectWait(10),
                                  .reconnectAttempts(-1) // infinite reconnect
                               ])
      }()
      
      private(set) var socket: SocketIOClient?
      weak var delegate: SocketDelegate?
      
      private override init() {
          super.init()
          if let socketManager = manager {
              self.socket = socketManager.defaultSocket
          } else {
              // Socket manager not initialized, socket is nil
          }
      }
    // MARK: - Connection
    
    func connectSocket() {
        guard socket?.status != .connected else { return }
        socket?.connect()
        establishConnection()
    }
    
    private func establishConnection() {
        socket?.removeAllHandlers()
        
        socket?.on(clientEvent: .connect) { [weak self] _, _ in
            // ✅ Socket Connected
            guard let self = self else { return }
            NotificationCenter.default.post(name: .socketConnected, object: nil)
            self.connectUser()
        }
        
        socket?.on(clientEvent: .reconnectAttempt) { _, _ in
           // 🔁 Reconnect Attempt
            NotificationCenter.default.post(name: .socketReconnectAttempt, object: nil)
        }
        
        socket?.on(clientEvent: .reconnect) { _, _ in
            // ✅ Reconnected
            NotificationCenter.default.post(name: .socketReconnected, object: nil)
        }
        
        socket?.on(clientEvent: .disconnect) { _, _ in
            // ❌ Disconnected
            NotificationCenter.default.post(name: .socketDisconnected, object: nil)
        }
        
        socket?.on(clientEvent: .error) { data, _ in
           // ⚠️ Socket Error
            NotificationCenter.default.post(name: .socketError, object: data.first)
        }
        
        addEventHandlers()
    }
    
    private func addEventHandlers() {
        socket?.on(SocketListeners.connectListener.instance) { [weak self] data, _ in
            // 📩 connect_listener event
            guard let self = self else { return }
            self.delegate?.listenedData(data: JSON(data), response: SocketListeners.connectListener.instance)
            NotificationCenter.default.post(name: .socketDataReceived, object: nil)
        }
        
        socket?.on(SocketListeners.productCommentList.instance) { [weak self] data, _ in
            // 📩 Product_Comment_list event
            guard let self = self else { return }
            self.delegate?.listenedData(data: JSON(data), response: SocketListeners.productCommentList.instance)
        }
    }
    
    // MARK: - Disconnect
    
    func closeConnection() {
        socket?.removeAllHandlers()
        socket?.disconnect()
        manager?.disconnect()
        // 🔌 Socket fully disconnected and handlers removed
    }
    
    func isConnected() -> Bool {
        return socket?.status == .connected
    }
}

// MARK: - Emitters

extension SocketIOManager {
    
    func connectUser() {
        guard let userID = Store.userDetails?.body?.id,
              !userID.isEmpty else {
            // ⚠️ Invalid authToken or userId
            return
        }
        
        let dict: [String: Any] = [SocketKeys.userId.instance: userID]
        
        socket?.emit(SocketEmitters.connectUser.instance, dict)
        
    }
    
    func getCommentList(productID: String, comment: String) {
        guard let userId = Store.userDetails?.body?.id else { return }
        let params: [String: Any] = [
            SocketKeys.userId.rawValue: userId,
            SocketKeys.productid.rawValue: productID,
            SocketKeys.comment.rawValue: comment
        ]
        socket?.emit(SocketEmitters.productComment.instance, params)
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let socketConnected = Notification.Name("SocketConnected")
    static let socketDisconnected = Notification.Name("SocketDisconnected")
    static let socketReconnectAttempt = Notification.Name("SocketReconnectAttempt")
    static let socketReconnected = Notification.Name("SocketReconnected")
    static let socketError = Notification.Name("SocketError")
    static let socketDataReceived = Notification.Name("SocketDataReceived")
}
