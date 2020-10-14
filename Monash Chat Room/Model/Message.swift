//
//  Message.swift
//  Monash Chat Room
//
//  Created by Kshitij Pandey on 14/10/20.
//

import Foundation
import MessageKit

struct Message {
    let text: String
    let chatRoomId: String
    let user: User
    let id: String
    let timestamp: Date
}

struct User {
    let senderId: String
    let name: String
}


extension Message: MessageType {
    var sender: SenderType {
        return Sender(senderId: user.senderId, displayName: user.name)
    }
    
    var messageId: String {
        return id
    }
    
    var sentDate: Date {
        return timestamp
    }
    
    var kind: MessageKind {
        return .text(text)
    }
}
