//
//  Constants.swift
//  Monash Chat Room
//
//  Created by Kshitij Pandey on 13/10/20.
//

import Foundation
import UIKit

struct Constants {
    static let ADD_NEW_ROOM_API_ROUTE = "/new-room"
    static let ALL_CHAT_ROOMS_CELL_VIEW_IDENTIFIER = "allChatRoomCellView"
    static let ALL_ROOMS_SEGUE_IDENTIFIER = "allRoomsSegue"
    static let ALL_ROOMS_TO_CHAT_ROOM_SEGUE_IDENTIFIER = "allRoomsToChatRoomSegue"
    static let FETCH_ALL_ROOMS_API_ROUTE = "/all-rooms"
    static let FETCH_ALL_ROOM_MESSAGES_API_ROUTE = "/all-messages"
    static let FETCH_ROOM_DETAILS_API_ROUTE = "/room"
    static let FETCH_USER_ROOMS_API_ROUTE = "/user-rooms"
    static let IOS_APP_BLUE_COLOR = UIColor(red: 0.08, green: 0.49, blue: 0.98, alpha: 1.00)
    static let JOIN_ROOM_API_ROUTE = "/join-room"
    static let LABEL_COLOR = UIColor(red: 0.60, green: 0.62, blue: 0.69, alpha: 1.00)
    static let LEAVE_ROOM_API_ROUTE = "/leave-room"
    static let LOGGED_IN_USER_EMAIL_KEY = "loggedInUserEmail"
    static let LOGIN_VIEW_STORYBOARD_ID = "loginView"
    static let MONASH_EMAIL_DOMAIN = "monash.edu"
    static let NO_USER_CHAT_ROOM_LABEL = "Looks like you are not a part of any chat room"
    static let NO_ROOMS_LABEL = "Looks like there are no rooms yet! Go ahead and create one"
    static var PRIMARY_APP_COLOR: UIColor { return UIColor(red: 1.00, green: 0.40, blue: 0.14, alpha: 1.00) }
//    static let SOCKET_URL = "http://localhost:3000"
    static let SOCKET_URL = "http://ec2-52-70-46-179.compute-1.amazonaws.com:3000"
    static let USER_CHAT_ROOMS_CELL_VIEW_IDENTIFIER = "userChatRoomCellView"
    static let USER_CHAT_ROOMS_TO_CHAT_ROOM_SEGUE_IDENTIFIER = "userChatRoomsToChatRoomSegue"
    static let USER_CHAT_ROOM_VIEW_STRORYBOARD_ID = "userChatRoomView"
    static let USER_LOGGED_IN_DEFAULT_KEY = "isUserLogedIn"
    static let USER_ROOMS_IDS_KEY = "userRoomIDs"
    
}
