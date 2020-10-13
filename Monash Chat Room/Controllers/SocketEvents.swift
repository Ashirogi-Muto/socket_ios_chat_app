//
//  EventEnums.swift
//  Monash Chat Room
//
//  Created by Kshitij Pandey on 13/10/20.
//

import Foundation

enum SocketEvents {
    case newRoom
    case seeAllRooms
    case sendNewMessage
    case sendNewMessageError
    case receiveNewMessage
    case fetchAllMessages
    case disconnect
}
