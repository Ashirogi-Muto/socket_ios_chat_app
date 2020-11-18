//
//  AllChatRoomsTableViewCell.swift
//  Monash Chat Room
//
//  Created by Sugandh Singhal on 16/11/20.
//

import UIKit

class AllChatRoomsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var roomNameLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var designView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
