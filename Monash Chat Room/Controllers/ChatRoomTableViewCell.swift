//
//  ChatRoomTableViewCell.swift
//  Monash Chat Room
//
//  Created by Sugandh Singhal on 18/11/20.
//

import UIKit

/**
 Class to manage the chat room details in list view
 */
class ChatRoomTableViewCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var borderView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
