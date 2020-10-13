//
//  SocketHelper.swift
//  Monash Chat Room
//
//  Created by Kshitij Pandey on 13/10/20.
//

import UIKit
import SocketIO

class SocketHelper {
    static let shared = SocketHelper()
    var socketClient: SocketIOClient? = nil
    let manager = SocketManager(socketURL: URL(string: Constants.SOCKET_URL)!, config: [.log(false), .compress])
    private init() {
        socketClient = manager.defaultSocket
    }
    
    func connectToSocket() {
        socketClient?.on(clientEvent: .connect, callback: { (data, ack) in
            print("CONNECTED \(data)")
        })
        socketClient?.connect()
    }
    
    func checkConnection() -> Bool {
        if socketClient?.manager?.status == .connected {
            return true
        }
        return false
    }
    
    func disconnectSocket() {
        socketClient?.disconnect()
        print("socket Disconnected")
    }
    
    enum Events {
        case fetchAllMessages
        case receiveNewMessage
        var emitterName: String {
            switch self {
            case .fetchAllMessages:
                return "fetchAllMessages"
            case .receiveNewMessage:
                return "receiveNewMessage"
            }
        }
        var listnerName: String {
            switch self {
            case .fetchAllMessages:
                return "fetchAllMessages"
            case .receiveNewMessage:
                return "receiveNewMessage"
            }
        }
        func emit(params: [String : Any]) {
            print("Emmiting \(emitterName)")
            SocketHelper.shared.socketClient?.emit(emitterName, params)
        }
        
        func listen(completion: @escaping (Any) -> Void) {
            SocketHelper.shared.socketClient?.on(listnerName) { (response, emitter) in
                print("RES \(response)")
                completion(response)
            }
        }
    }
}
