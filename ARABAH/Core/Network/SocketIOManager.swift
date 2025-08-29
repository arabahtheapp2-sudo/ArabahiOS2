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
    
    private let manager = SocketManager(socketURL: URL(string: SocketKeys.socketBaseUrl.rawValue)!,
                                        config: [
                                            .compress,
                                            .log(true),
                                            .reconnects(true),
                                            .reconnectWait(10),
                                            .reconnectAttempts(-1) // infinite reconnect
                                        ])
    
    private(set) var socket: SocketIOClient!
    weak var delegate: SocketDelegate?
    
    private override init() {
        super.init()
        self.socket = manager.defaultSocket
    }
    
    // MARK: - Connection
    
    func connectSocket() {
        guard socket.status != .connected else { return }
        socket.connect()
        establishConnection()
    }
    
    private func establishConnection() {
        socket.removeAllHandlers()
        
        socket.on(clientEvent: .connect) { [weak self] data, ack in
            print("✅ Socket Connected")
            NotificationCenter.default.post(name: .socketConnected, object: nil)
            self?.connectUser()
        }
        
        socket.on(clientEvent: .reconnectAttempt) { [weak self] data, ack in
            guard let _ = self else { return }
            print("🔁 Reconnect Attempt")
            NotificationCenter.default.post(name: .socketReconnectAttempt, object: nil)
        }
        
        socket.on(clientEvent: .reconnect) { [weak self] data, ack in
            guard let _ = self else { return }
            print("✅ Reconnected")
            NotificationCenter.default.post(name: .socketReconnected, object: nil)
        }
        
        socket.on(clientEvent: .disconnect) { [weak self] data, ack in
            guard let _ = self else { return }
            print("❌ Disconnected")
            NotificationCenter.default.post(name: .socketDisconnected, object: nil)
        }
        
        socket.on(clientEvent: .error) { [weak self] data, ack in
            guard let _ = self else { return }
            print("⚠️ Socket Error: \(data)")
            NotificationCenter.default.post(name: .socketError, object: data.first)
        }
        
        addEventHandlers()
    }
    
    private func addEventHandlers() {
        socket.on(SocketListeners.connectListener.instance) { [weak self] data, ack in
            print("📩 connect_listener event")
            self?.delegate?.listenedData(data: JSON(data), response: SocketListeners.connectListener.instance)
            NotificationCenter.default.post(name: .socketDataReceived, object: nil)
        }
        
        socket.on(SocketListeners.Product_Comment_list.instance) { [weak self] data, ack in
            print("📩 Product_Comment_list event")
            self?.delegate?.listenedData(data: JSON(data), response: SocketListeners.Product_Comment_list.instance)
        }
    }
    
    // MARK: - Disconnect
    
    func closeConnection() {
        socket.removeAllHandlers()
        socket.disconnect()
        manager.disconnect()
        print("🔌 Socket fully disconnected and handlers removed.")
    }
    
    func isConnected() -> Bool {
        return socket.status == .connected
    }
}

// MARK: - Emitters

extension SocketIOManager {
    
    func connectUser() {
        guard let userID = Store.userDetails?.body?.id,
              !userID.isEmpty else {
            print("⚠️ Invalid authToken or userId")
            return
        }
        
        let dict: [String: Any] = [SocketKeys.userId.instance: userID]
        
        socket.emit(SocketEmitters.connectUser.instance, dict)
        
    }
    
    func getCommentList(productID: String, comment: String) {
        guard let userId = Store.userDetails?.body?.id else { return }
        let params: [String: Any] = [
            SocketKeys.userId.rawValue: userId,
            SocketKeys.Productid.rawValue: productID,
            SocketKeys.comment.rawValue: comment
        ]
        socket.emit(SocketEmitters.Product_Comment.instance, params)
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

