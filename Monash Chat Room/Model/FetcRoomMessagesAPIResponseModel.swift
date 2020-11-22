//
//  FetcRoomMessagesAPIResponseModel.swift
//  Monash Chat Room
//
//  Created by Kshitij Pandey on 20/10/20.
//

import Foundation

/**
 Struct to define the messages
 */

struct FetchRoomMessagesModel: Decodable {
    let message: String?
    let result: RoomMessages?
}

struct RoomMessages: Decodable {
    let messages: [MessageDetails]?
}

/**
 Individual message properties
 Each individual message object will have these properties
 */
struct MessageDetails: Decodable {
    let text: String
    let chatRoomId: String
    let senderId: String
    let id: String
    let timestamp: String
}
