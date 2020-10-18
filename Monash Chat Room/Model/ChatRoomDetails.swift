//
//  ChatRoomDetails.swift
//  Monash Chat Room
//
//  Created by Kshitij Pandey on 18/10/20.
//

import Foundation

struct ChatRoomDetails: Decodable {
    let createdAt: String
    let createdBy: String
    let id: String
    let name: String
    let tag: String
}
