//
//  FetcRoomMessagesAPIResponseModel.swift
//  Monash Chat Room
//
//  Created by Kshitij Pandey on 20/10/20.
//

import Foundation

struct FetchRoomMessagesModel: Decodable {
    let message: String?
    let result: RoomMessages?
}

struct RoomMessages: Decodable {
    let messages: [MessageDetails]?
}

struct MessageDetails: Decodable {
    let text: String
    let chatRoomId: String
    let senderId: String
    let id: String
    let timestamp: String
}
