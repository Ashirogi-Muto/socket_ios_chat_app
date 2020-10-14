//
//  Constants.swift
//  Monash Chat Room
//
//  Created by Kshitij Pandey on 13/10/20.
//

import Foundation
import UIKit

struct Constants {
    static let ALL_CHAT_ROOMS_CELL_VIEW_IDENTIFIER = "allChatRoomCellView"
    static let ALL_ROOMS_SEGUE_IDENTIFIER = "allRoomsSegue"
    static let ALL_ROOMS_TO_CHAT_ROOM_SEGUE_IDENTIFIER = "allRoomsToChatRoomSegue"
    static let IOS_APP_BLUE_COLOR = UIColor(red: 0.08, green: 0.49, blue: 0.98, alpha: 1.00)
    static let PRIMARY_APP_COLOR = UIColor(red: 1.00, green: 0.40, blue: 0.14, alpha: 1.00)
    static let SOCKET_URL = "http://localhost:3000"
    static let USER_CHAT_ROOMS_CELL_VIEW_IDENTIFIER = "userChatRoomCellView"
    static let USER_CHAT_ROOMS_TO_CHAT_ROOM_SEGUE_IDENTIFIER = "userChatRoomsToChatRoomSegue"
}
