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
    var delegate: SocketConnectionDelegate?
    public init() {
        socketClient = manager.defaultSocket
    }
    
    func connectToSocket() {
        socketClient?.on(clientEvent: .connect, callback: { (data, ack) in
            print("CONNECTED \(data)")
            print("Calling delegate")
            self.delegate?.connectedToSocket(isConnected: true)
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
        case receiveNewMessage
        case sendNewMessage
        var emitterName: String {
            switch self {
            case .receiveNewMessage:
                return "receiveNewMessage"
            case .sendNewMessage:
                return "sendNewMessage"
            }
        }
        var listnerName: String {
            switch self {
            case .receiveNewMessage:
                return "receiveNewMessage"
            case .sendNewMessage:
                return "sendNewMessage"
            }
        }
        func emit(params: [String : Any]) {
            SocketHelper.shared.socketClient?.emit(emitterName, params)
        }
        
        func listen(completion: @escaping (Any) -> Void) {
            SocketHelper.shared.socketClient?.on(listnerName) { (response, emitter) in
                completion(response)
            }
        }
    }
}
