//
//  ChatRoomController.swift
//  Monash Chat Room
//
//  Created by Kshitij Pandey on 14/10/20.
//

import UIKit
import MessageKit
import InputBarAccessoryView

/**
 The controller responsible to manage the individual chat room
 Lets the user send, receive, and see the messages in a chat room
 */
class ChatRoomController: MessagesViewController, SocketConnectionDelegate {
    
    var messages: [Message] = []
    var messagesSortedByTimestamp: [Message] = []
    var user: User!
    var selectedRoomDetails: ChatRoomDetails?
    var indicator = UIActivityIndicatorView()
    var logedInUserEmail: String?
    var userRoomIds: [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let socketHelper = SocketHelper()
        socketHelper.delegate = self
        let userDefault = UserDefaults.standard
        logedInUserEmail = userDefault.string(forKey: Constants.LOGGED_IN_USER_EMAIL_KEY)
        userRoomIds = userDefault.stringArray(forKey: Constants.USER_ROOMS_IDS_KEY)
        self.title = selectedRoomDetails?.name ?? "No Room Name"
        user = User(senderId: logedInUserEmail!, name: logedInUserEmail!)
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        showMessageTimestampOnSwipeLeft = true
        messageInputBar.delegate = self
        messageInputBar.inputTextView.placeholderLabel.text = "Type here..."
        messageInputBar.inputTextView.placeholderTextColor = Constants.PRIMARY_APP_COLOR
        let controller = MessagesViewController()
        controller.resignFirstResponder()
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.center = view.center
        indicator.hidesWhenStopped = true
        indicator.backgroundColor = UIColor.clear
        view.addSubview(indicator)
        indicator.startAnimating()
        fetchMessagesForTheRoom()
        initializeListenerForMessages()
        doesUserBelongToTheRoom()
    }
    
    
    //Check if the user belongs to the selected room
    func doesUserBelongToTheRoom() {
        if checkIfUserRoomIdsKeyExist() == false {
            fetchUserChatRooms()
            makeUserJoinTheRoom()
        }
        else {
            makeUserJoinTheRoom()
        }
    }
    
    /**
     If the user has not joined the selected room
     ask the user if it wishes to join the room
     */
    func makeUserJoinTheRoom() {
        if userRoomIds?.contains(selectedRoomDetails!.id) == false {
            messageInputBar.sendButton.isEnabled = false
            messageInputBar.isHidden = true
            let alertJoinAction = UIAlertAction(title: "Join", style: .default) { _ in
                self.saveUserToRoom()
            }
            let alertCancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            let alert = UIAlertController(title: "", message: "Looks like you have not joined this room yet!", preferredStyle: .alert)
            alert.addAction(alertJoinAction)
            alert.addAction(alertCancelAction)
            present(alert, animated: true, completion: nil)
        }
    }
    /**
     If the user wants to join the room
     make an api call to save the user to the rooom
     */
    func saveUserToRoom() {
        indicator.startAnimating()
        let url = Constants.SOCKET_URL + Constants.JOIN_ROOM_API_ROUTE + "/" + selectedRoomDetails!.id
        let urlWithQuery = url + "?userEmail=" + logedInUserEmail!
        let finalUrl = URL(string: urlWithQuery)
        var request = URLRequest(url: finalUrl!)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.indicator.stopAnimating()
                    self.showAlert(title: "Oop!", message: "Could not add you to this room! Please try again.", actionTitle: "Ok")
                }
            }
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    self.indicator.stopAnimating()
                    self.messageInputBar.sendButton.isEnabled = true
                    self.messageInputBar.isHidden = false
                }
            }
            
        }
        task.resume()
    }
    
    /**
     Sort all the message by timestamp and
    convert them to MessageKit Message object type
     */
    func convertFetchedMessgesToMessageKitType(allMessages: [MessageDetails]) {
        let sortedMessages: [MessageDetails] = allMessages.sorted(by: { (first, next) -> Bool in
            let firstTimestamp = convertStringTimestampToDateTimestamp(timestamp: first.timestamp)
            let nextTimestamp = convertStringTimestampToDateTimestamp(timestamp: next.timestamp)
            return firstTimestamp < nextTimestamp
        })
        for message in sortedMessages {
            let timestamp = convertStringTimestampToDateTimestamp(timestamp: message.timestamp)
            let messageSender = User(senderId: message.senderId, name: message.senderId.prefix(1).uppercased())
            let newMessage = Message(text: message.text, chatRoomId: selectedRoomDetails!.id, user: messageSender, id: message.id, timestamp: timestamp)
            messagesSortedByTimestamp.append(newMessage)
        }
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToBottom(animated: true)
    }
    
    /**
     Date to String conversion
     */
    func convertStringTimestampToDateTimestamp(timestamp: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone(abbreviation: "Australia/Melbourne") as TimeZone?
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let messageTimestamp = dateFormatter.date(from: timestamp)!
        return messageTimestamp
    }
    
    
    /**
     Fetch all the messages for the selected room
     */
    func fetchMessagesForTheRoom() {
        let url = Constants.SOCKET_URL + Constants.FETCH_ALL_ROOM_MESSAGES_API_ROUTE + "/" + selectedRoomDetails!.id
        let finalUrl = URL(string: url)
        let task = URLSession.shared.dataTask(with: finalUrl!) { (data, response, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.indicator.stopAnimating()
                    self.showAlert(title: "Error", message: "Could not fetch all the messages! Please try again.", actionTitle: "Ok")
                }
                return
            }
            if let safeData = data {
                let decoder = JSONDecoder()
                do {
                    let responseData = try decoder.decode(FetchRoomMessagesModel.self, from: safeData)
                    DispatchQueue.main.async {
                        self.indicator.stopAnimating()
                        self.convertFetchedMessgesToMessageKitType(allMessages: (responseData.result?.messages)!)
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.indicator.stopAnimating()
                        self.showAlert(title: "Error", message: "Could not fetch all the messages! Please try again.", actionTitle: "Ok")
                    }
                }
            }
        }
        task.resume()
    }
    
    /**
     Initialize `receiveNewMessage` event listener to update the mssage list
     whenever a new message is sent in the selected room
     */
    func initializeListenerForMessages() {
        SocketHelper.Events.receiveNewMessage.listen { [self] (data) in
            do {
                if let arr = data as? [[String: Any]] {
                    let messageDataJson = try JSONSerialization.data(withJSONObject: arr[0])
                    let message = try JSONDecoder().decode(MessageDetails.self, from: messageDataJson)
                    if message.chatRoomId == self.selectedRoomDetails!.id {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
                        let messageTimestamp = convertStringTimestampToDateTimestamp(timestamp: message.timestamp)
                        let messageSender = User(senderId: message.senderId, name: message.senderId.prefix(1).uppercased())
                        let newMessage = Message(text: message.text, chatRoomId: self.selectedRoomDetails!.id, user: messageSender, id: message.id, timestamp: messageTimestamp)
                        messagesSortedByTimestamp.append(newMessage)
                        messagesCollectionView.reloadData()
                        messagesCollectionView.scrollToBottom(animated: true)
                        
                    }
                }
            } catch let error {
                print("ERROR IN <><><>< \(error.localizedDescription)")
            }
        }
    }
    
    /**
     While checking if the user belongs to the selected room
     if user's rooms are not available make an API call to fetch the use rooms
     then check if the selected  room belongs in the user's chat rooms
     */
    func fetchUserChatRooms() {
        indicator.startAnimating()
        let url = Constants.SOCKET_URL + Constants.FETCH_USER_ROOMS_API_ROUTE + "/" + logedInUserEmail!
        let finalUrl = URL(string: url)
        let task = URLSession.shared.dataTask(with: finalUrl!) { (data, response, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.indicator.stopAnimating()
                    self.showAlert(title: "Error", message: "Could not fetch your rooms! PLease try again.", actionTitle: "Ok")
                }
                return
            }
            if let safeData = data {
                let decoder = JSONDecoder()
                do {
                    let responseData = try decoder.decode(FetchRoomsAPIResponse.self, from: safeData)
                    DispatchQueue.main.async { [self] in
                        let allRoomIds: [String] = responseData.result.rooms.map{ $0.id }
                        let defaults = UserDefaults.standard
                        defaults.set(allRoomIds, forKey: Constants.USER_ROOMS_IDS_KEY)
                        self.indicator.stopAnimating()
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.indicator.stopAnimating()
                        self.showAlert(title: "Error", message: "Could not fetch your rooms! PLease try again.", actionTitle: "Ok")
                    }
                }
            }
        }
        task.resume()
    }
    
    func showAlert(title: String, message: String, actionTitle: String) {
        let alertAction = UIAlertAction(title: actionTitle, style: .default, handler: nil)
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
    }
    
    func checkIfUserRoomIdsKeyExist() -> Bool {
        return UserDefaults.standard.array(forKey: Constants.USER_ROOMS_IDS_KEY) != nil
    }
    
    func connectedToSocket(isConnected: Bool) {
    }
    
    /**
     Generate a color for user's avatar based on its email address
     Taken from a StackOverflow solution
     The logged in user's avatar will have the app's primary color as the avatar color
     this function generates colors for the other user's avatar in the room
     */
    func generateRandomAvatarColor(id: String) -> UIColor {
        let hash = abs(id.hashValue)
        let colorNum = hash % (256*256*256)
        let red = colorNum >> 16
        let green = (colorNum & 0x00FF00) >> 8
        let blue = (colorNum & 0x0000FF)
        let userColor = UIColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: 1.0)
        return userColor
    }
}


/**
 Message kit delegate functions
 The below extensions are for configuring the MessageKit layout and data source
 */
extension ChatRoomController: MessagesDataSource {
    func currentSender() -> SenderType {
        return Sender(senderId: user.senderId, displayName: user.name)
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messagesSortedByTimestamp.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messagesSortedByTimestamp[indexPath.section]
    }
    
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 15
    }
}

extension ChatRoomController: MessagesLayoutDelegate {
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let isFromCurrentLoggedInUser = isFromCurrentSender(senderId: message.sender.senderId)
        if isFromCurrentLoggedInUser == true {
            return MessageStyle.bubbleTail(.bottomRight, .pointedEdge)
        }
        else {
            return MessageStyle.bubbleTail(.bottomLeft, .pointedEdge)
        }
    }
    
    func isFromCurrentSender(senderId: String) -> Bool {
        if senderId == logedInUserEmail! {
            return true
        }
        else {
            return false
        }
    }
    
}

extension ChatRoomController: MessagesDisplayDelegate {
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.setCorner(radius: 15)
        
        if isFromCurrentSender(senderId: message.sender.senderId) {
            avatarView.backgroundColor = Constants.PRIMARY_APP_COLOR
        }
        else {
            avatarView.backgroundColor = generateRandomAvatarColor(id: message.sender.senderId)
        }
        avatarView.initials = message.sender.displayName
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return Constants.IOS_APP_BLUE_COLOR
    }
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return .white
    }
}

/**
 Take the text from the input field
 and emit the message in the event to the server
 */
extension ChatRoomController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        if text.count > 0 {
            let trimmedString = text.trimmingCharacters(in: .whitespacesAndNewlines)
            SocketHelper.Events.sendNewMessage.emit(params: ["text" : trimmedString, "chatRoomId": selectedRoomDetails!.id, "senderId": logedInUserEmail!, "id": UUID().uuidString])
            inputBar.inputTextView.text = ""
            messagesCollectionView.scrollToBottom(animated: true)
        }
    }
}
