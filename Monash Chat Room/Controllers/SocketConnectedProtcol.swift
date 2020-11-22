//
//  SocketConnectedProtcol.swift
//  Monash Chat Room
//
//  Created by Kshitij Pandey on 18/10/20.
//

import Foundation

/**
 Protocol to let other classes know that Socket connection was
 successfull or not
 */
protocol SocketConnectionDelegate {
    func connectedToSocket(isConnected: Bool)
}
