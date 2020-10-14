//
//  ChatRoomController.swift
//  Monash Chat Room
//
//  Created by Kshitij Pandey on 14/10/20.
//

import UIKit
import MessageKit
import InputBarAccessoryView
class ChatRoomController: MessagesViewController {
    var messages: [Message] = []
    var user: User!
    override func viewDidLoad() {
        super.viewDidLoad()
        user = User(senderId: UUID().uuidString, name: "Kshitij")
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        messageInputBar.inputTextView.placeholderLabel.text = "Type here..."
        messageInputBar.inputTextView.placeholderTextColor = Constants.PRIMARY_APP_COLOR
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
    
//    func messageTopLabelAttributedText(for message: MessageType,at indexPath: IndexPath) -> NSAttributedString? {
//        let message = messages[indexPath.section]
//        let dateFormatterGet = DateFormatter()
//        dateFormatterGet.dateFormat = "HH:mm"
//        return NSAttributedString(
//            string: dateFormatterGet.string(from: message.timestamp),
//            attributes: [.font: UIFont.systemFont(ofSize: 12)])
//    }
}

extension ChatRoomController: MessagesLayoutDelegate {
    func heightForLocation(message: MessageType, at indexPath: IndexPath, with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        return MessageStyle.bubbleTail(.bottomLeft, .pointedEdge)
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
//    func configureAccessoryView(_ accessoryView: UIView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
//        let message = messages[indexPath.row]
//        let button = UIButton(type: .infoLight)
//        button.tintColor = .white
//        let dateFormatterGet = DateFormatter()
//        dateFormatterGet.dateFormat = "HH:mm"
//        button.titleLabel?.text = dateFormatterGet.string(from: message.timestamp)
//        accessoryView.addSubview(button)
//        button.frame = accessoryView.bounds
//        button.isUserInteractionEnabled = true
//        accessoryView.layer.cornerRadius = accessoryView.frame.height / 2
//    }
}


extension ChatRoomController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let newMessage = Message(text: text, chatRoomId: "123", user: user, id: UUID().uuidString, timestamp: Date())
        messages.append(newMessage)
        inputBar.inputTextView.text = ""
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToBottom(animated: true)
    }
}
