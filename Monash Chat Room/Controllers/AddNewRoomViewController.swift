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
    var indicator = UIActivityIndicatorView()
    override func viewDidLoad() {
        super.viewDidLoad()
        addNewRoomButton.layer.cornerRadius = 5
        nameErrorMessageLabel.isHidden = true
        tagErrorMessageLabel.isHidden = true
        indicator.style = UIActivityIndicatorView.Style.medium
        indicator.center = self.view.center
        view.addSubview(indicator)
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func addNewRoomAction(_ sender: Any) {
        validationUIReset()
        let validation = inputValidation()
        if validation == true{
            
            indicator.startAnimating()
            indicator.backgroundColor = UIColor.clear
            //
            print("validated")
            // SocketHelper.Events.addNewRoom.emit(params: ["name": roomNameInput.text!, "tag": roomTagInput.text!, "userId": "kpan0021@student.monash.edu"])
            
        } else{
            popUpMessage()
            indicator.stopAnimating()
            self.indicator.hidesWhenStopped = true
        }
    }
    
    
    // delegate mein listen karna hai
    
    
    func inputValidation () -> Bool{
        var validation = true
        let trimmedRoomName = (roomNameInput.text)?.trimmingCharacters(in: .whitespaces)
        let trimmedRoomTag = (roomTagInput.text)?.trimmingCharacters(in: .whitespaces)
        let rangeRoomName = NSRange(location: 0, length: trimmedRoomName!.utf16.count)
        let rangeRoomTag = NSRange(location: 0, length: trimmedRoomTag!.utf16.count)
        let regex = try! NSRegularExpression(pattern: "[^A-Za-z0-9]")
        
        if trimmedRoomName!.count < 1 {
            validation = false
            validationUI(inputField: roomNameInput,messageLabel: nameErrorMessageLabel,message: "Please enter Room Name!" )
            
            
        }
        if trimmedRoomTag!.count < 1 {
            validation = false
            validationUI(inputField: roomTagInput,messageLabel: tagErrorMessageLabel,message: "Please enter Room Tag!" )
            
        }
        
        if trimmedRoomName!.count > 1 && regex.firstMatch(in: trimmedRoomName!, options: [], range: rangeRoomName) != nil {
            validation = false
            validationUI(inputField: roomNameInput,messageLabel: nameErrorMessageLabel,message: "Please enter correct Room Name!" )
        }
        
        if trimmedRoomTag!.count > 1 && regex.firstMatch(in: trimmedRoomTag!, options: [], range: rangeRoomTag) != nil   {
            validation = false
            validationUI(inputField: roomTagInput,messageLabel: tagErrorMessageLabel,message: "Please enter correct Room Tag!" )
        }
        return validation
    }
    
    
    
    // This is validation UI
    func validationUI(inputField: UITextField!, messageLabel: UILabel!, message: String){
        inputField.backgroundColor = UIColor.yellow
        inputField.layer.borderColor = UIColor.orange.cgColor
        inputField.layer.borderWidth = 1.0
        messageLabel.isHidden = false
        messageLabel.text = message
    }
    
    // This is validation UI reset
    func validationUIReset(){
        roomNameInput.backgroundColor = UIColor.white
        roomNameInput.layer.borderColor = UIColor.systemGray5.cgColor
        roomNameInput.layer.cornerRadius = 5.0
        nameErrorMessageLabel.isHidden = true
        roomTagInput.backgroundColor = UIColor.white
        roomTagInput.layer.borderColor = UIColor.systemGray5.cgColor
        roomTagInput.layer.cornerRadius = 5.0
        tagErrorMessageLabel.isHidden = true
    }
    
    
    
    // alert message for the save exhibition if the information is not valid.
    func popUpMessage (){
        let alertMessage = UIAlertController(title: "Alert", message: "New Room cannot be Added", preferredStyle: UIAlertController.Style.alert)
        alertMessage.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alertMessage, animated: true, completion: nil)
    }
    
    
    
}
