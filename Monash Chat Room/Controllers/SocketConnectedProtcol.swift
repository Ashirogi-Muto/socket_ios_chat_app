//
//  SocketConnectedProtcol.swift
//  Monash Chat Room
//
//  Created by Kshitij Pandey on 18/10/20.
//

import Foundation

protocol SocketConnectionDelegate {
    func connectedToSocket(isConnected: Bool)
}
