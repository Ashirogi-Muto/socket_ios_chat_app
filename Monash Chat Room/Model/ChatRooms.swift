//
//  ChatRoomsModel.swift
//  Monash Chat Room
//
//  Created by Kshitij Pandey on 18/10/20.
//

import Foundation

/**
 Decodable struct to extract the chat rooms from the API call
 */
struct ChatRooms: Decodable {
    let userId: String?
    let rooms: [ChatRoomDetails]
}
