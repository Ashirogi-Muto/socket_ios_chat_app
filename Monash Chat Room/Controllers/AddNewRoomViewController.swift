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
    }
    
    
    @IBAction func addNewRoomAction(_ sender: Any) {
        validationUIReset()
        let validation = inputValidation()
        if validation == true{
            indicator.startAnimating()
            indicator.backgroundColor = UIColor.clear
            addNewRoomButton.isEnabled = false
            print(" Data entered to create room is valid data")
            let roomId = UUID()
            let userDefault = UserDefaults.standard
            let loggedInUserId = userDefault.string(forKey: Constants.LOGGED_IN_USER_EMAIL_KEY)
            let postString = "name=\(roomNameInput.text!)&tag=\(roomTagInput.text!)&userId=\(loggedInUserId!)&roomId=\(roomId)"
            createNewRoom(inputParameters: postString)
            // SocketHelper.Events.addNewRoom.emit(params: ["name": roomNameInput.text!, "tag": roomTagInput.text!, "userId": "kpan0021@student.monash.edu"])
            
        } else{
            indicator.stopAnimating()
            self.indicator.hidesWhenStopped = true
        }
    }
    
    func createNewRoom(inputParameters: String){
        let urlString = Constants.SOCKET_URL + Constants.ADD_NEW_ROOM_API_ROUTE
        
        // Prepare URL
        let url = URL(string:urlString)
        guard let requestUrl = url else { fatalError() }
        // Prepare URL Request Object
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        // Set HTTP Request Body
        request.httpBody = inputParameters.data(using: String.Encoding.utf8);
        // Perform HTTP Request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        // Check for Error
        if let error = error {
                print("Error took place \(error)")
                DispatchQueue.main.async {
                    self.popUpMessage(message: "New Room cannot be added")
                    self.stopingIndicator()
                }
                return
            }
         // Convert HTTP Response Data to a String
         if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("New Room has been added")
                print("Response data string:\n \(dataString)")
                DispatchQueue.main.async {
                    self.popUpMessage(message: "New Room is added")
                    self.stopingIndicator()
                    self.roomNameInput.text = nil
                    self.roomTagInput.text = nil
                }
            }
        }
        task.resume()
    }
    
    func inputValidation () -> Bool{
        var validation = true
        let trimmedRoomName = (roomNameInput.text)?.trimmingCharacters(in: .whitespaces)
        let trimmedRoomTag = (roomTagInput.text)?.trimmingCharacters(in: .whitespaces)
        let rangeRoomName = NSRange(location: 0, length: trimmedRoomName!.utf16.count)
        let rangeRoomTag = NSRange(location: 0, length: trimmedRoomTag!.utf16.count)
        let regex = try! NSRegularExpression(pattern: "[^A-Za-z0-9\\s]")
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
    
    
    // alert message for the save exhibition if the information is not valid.
    func popUpMessage (message: String){
        let alertMessage = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
        alertMessage.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alertMessage, animated: true, completion: nil)
    }
    
    func stopingIndicator(){
        self.indicator.stopAnimating()
        self.indicator.hidesWhenStopped = true
        self.addNewRoomButton.isEnabled = true
    }
    
    // This is validation UI
    func validationUI(inputField: UITextField!, messageLabel: UILabel!, message: String){
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
    
    
}
