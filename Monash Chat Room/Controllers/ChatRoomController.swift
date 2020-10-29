//
//  ChatRoomController.swift
//  Monash Chat Room
//
//  Created by Kshitij Pandey on 14/10/20.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import SwiftDate
class ChatRoomController: MessagesViewController, SocketConnectionDelegate {
    var messages: [Message] = []
    var user: User!
    var selectedRoomDetails: ChatRoomDetails?
    var indicator = UIActivityIndicatorView()
    var logedInUserEmail: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let socketHelper = SocketHelper()
        socketHelper.delegate = self
//        socketHelper.connectToSocket()
        let userDefault = UserDefaults.standard
        logedInUserEmail = userDefault.string(forKey: Constants.LOGGED_IN_USER_EMAIL_KEY)
        self.title = selectedRoomDetails?.name ?? "No Room Name"
        user = User(senderId: logedInUserEmail!, name: logedInUserEmail!)
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        messageInputBar.inputTextView.placeholderLabel.text = "Type here..."
        messageInputBar.inputTextView.placeholderTextColor = Constants.PRIMARY_APP_COLOR
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.center = view.center
        indicator.hidesWhenStopped = true
        indicator.backgroundColor = UIColor.clear
        view.addSubview(indicator)
        indicator.startAnimating()
        fetchMessagesForTheRoom()
        initializeListenerForMessages()
    }
    
    func convertFetchedMessgesToMessageKitType(allMessages: [MessageDetails]) {
        let sortedMessages: [MessageDetails] = allMessages.sorted(by: { (first, next) -> Bool in
            let firstTimestamp = convertStringTimestampToDateTimestamp(timestamp: first.timestamp)
            let nextTimestamp = convertStringTimestampToDateTimestamp(timestamp: next.timestamp)
            return firstTimestamp < nextTimestamp
        })
        for message in sortedMessages {
            let timestamp = convertStringTimestampToDateTimestamp(timestamp: message.timestamp)
            let newMessage = Message(text: message.text, chatRoomId: selectedRoomDetails!.id, user: user, id: message.id, timestamp: timestamp)
            messages.append(newMessage)
        }
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToBottom(animated: true)
    }
    
    func convertStringTimestampToDateTimestamp(timestamp: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone(abbreviation: "Australia/Melbourne") as TimeZone?
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let messageTimestamp = dateFormatter.date(from: timestamp)!
        return messageTimestamp
    }
    
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
                        let newMessage = Message(text: message.text, chatRoomId: self.selectedRoomDetails!.id, user: self.user, id: message.id, timestamp: messageTimestamp)
                        messages.append(newMessage)
                        messagesCollectionView.reloadData()
                        messagesCollectionView.scrollToBottom(animated: true)
                        
                    }
                }
            } catch let error {
                print("ERROR IN <><><>< \(error.localizedDescription)")
            }
        }
    }
    
    func connectedToSocket(isConnected: Bool) {
    }
    
    func showAlert(title: String, message: String, actionTitle: String) {
        let alertAction = UIAlertAction(title: actionTitle, style: .default, handler: nil)
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
    }
}

extension ChatRoomController: MessagesDataSource {
    func currentSender() -> SenderType {
        return Sender(senderId: UUID().uuidString, displayName: user.name)
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 12
    }
}

extension ChatRoomController: MessagesLayoutDelegate {
    func heightForLocation(message: MessageType, at indexPath: IndexPath, with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let message = messages[indexPath.row]
        return isFromCurrentSender(message: message) ? MessageStyle.bubbleTail(.bottomRight, .pointedEdge) : MessageStyle.bubbleTail(.bottomLeft, .pointedEdge)
    }
    
    func isFromCurrentSender(message: MessageType) -> Bool {
        if message.sender.senderId == logedInUserEmail {
            return true
        }
        return false
    }
}

extension ChatRoomController: MessagesDisplayDelegate {
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let color = Constants.PRIMARY_APP_COLOR
        avatarView.backgroundColor = color
        avatarView.initials = user.name.prefix(1).uppercased()
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return Constants.IOS_APP_BLUE_COLOR
    }
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return .white
    }
}


extension ChatRoomController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        SocketHelper.Events.sendNewMessage.emit(params: ["text" : text, "chatRoomId": selectedRoomDetails!.id, "senderId": logedInUserEmail!, "id": UUID().uuidString])
        inputBar.inputTextView.text = ""
        messagesCollectionView.scrollToBottom(animated: true)
    }
}
