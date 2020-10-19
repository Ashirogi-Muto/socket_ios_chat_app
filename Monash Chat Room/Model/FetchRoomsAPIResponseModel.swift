//
//  APIResponseModel.swift
//  Monash Chat Room
//
//  Created by Kshitij Pandey on 19/10/20.
//

import Foundation

struct FetchRoomsAPIResponse: Decodable {
    let message: String
    let result: ResultModel
}

struct ResultModel: Decodable {
    let rooms: [ChatRoomDetails]
}
