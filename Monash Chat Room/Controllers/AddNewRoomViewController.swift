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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addNewRoomButton.layer.cornerRadius = 5
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func addNewRoomAction(_ sender: Any) {
        
    }
    
}
