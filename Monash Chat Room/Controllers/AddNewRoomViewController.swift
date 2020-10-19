//
//  AddNewRoomViewController.swift
//  Monash Chat Room
//
//  Created by Kshitij Pandey on 14/10/20.
//

import UIKit

class AddNewRoomViewController: UIViewController {
    
    @IBOutlet weak var roomNameInput: UITextField!
    @IBOutlet weak var roomTagInput: UITextField!
    @IBOutlet weak var addNewRoomButton: UIButton!
    @IBOutlet weak var nameErrorMessageLabel: UILabel!
    @IBOutlet weak var tagErrorMessageLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        addNewRoomButton.layer.cornerRadius = 5
        nameErrorMessageLabel.isHidden = true
        tagErrorMessageLabel.isHidden = true
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func addNewRoomAction(_ sender: Any) {
        inputValidation()
        
    }
    
   
    // reset all the field inputs
    // delegate mein listen karna hai
    
    
    func inputValidation () {
        let trimmedRoomName = (roomNameInput.text)?.trimmingCharacters(in: .whitespaces)
        let trimmedRoomTag = (roomTagInput.text)?.trimmingCharacters(in: .whitespaces)
        let set = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890")

        if (trimmedRoomName!.count < 1) {
                roomNameInput.backgroundColor = UIColor.yellow
                roomNameInput.layer.borderColor = UIColor.orange.cgColor
                roomNameInput.layer.borderWidth = 1.0
                nameErrorMessageLabel.isHidden = false
                nameErrorMessageLabel.text = "Please enter Room Name!"
                
               }
        if (trimmedRoomTag!.count < 1) {
                roomTagInput.backgroundColor = UIColor.yellow
                roomTagInput.layer.borderColor = UIColor.orange.cgColor
                roomTagInput.layer.borderWidth = 1.0
                tagErrorMessageLabel.isHidden = false
                tagErrorMessageLabel.text = "Please enter Room Tag!"
               }
        
        if (trimmedRoomName!.rangeOfCharacter(from: set.inverted) != nil ) {
            roomNameInput.backgroundColor = UIColor.yellow
            roomNameInput.layer.borderColor = UIColor.orange.cgColor
            roomNameInput.layer.borderWidth = 1.0
            nameErrorMessageLabel.isHidden = false
            nameErrorMessageLabel.text = "Please enter correct Room Name!"
        }
        
        if (trimmedRoomTag!.rangeOfCharacter(from: set.inverted) != nil ) {
            roomTagInput.backgroundColor = UIColor.yellow
            roomTagInput.layer.borderColor = UIColor.orange.cgColor
            roomTagInput.layer.borderWidth = 1.0
            tagErrorMessageLabel.isHidden = false
            tagErrorMessageLabel.text = "Please enter correct Room Tag!"
        }
      
    }
    
    
}
