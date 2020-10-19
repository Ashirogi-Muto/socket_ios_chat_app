//
//  ChatRoomsModel.swift
//  Monash Chat Room
//
//  Created by Kshitij Pandey on 18/10/20.
//

import Foundation

struct ChatRooms: Decodable {
    let userId: String?
    let rooms: [ChatRoomDetails]
}
