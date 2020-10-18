//
//  ViewController.swift
//  Monash Chat Room
//
//  Created by Kshitij Pandey on 13/10/20.
//

import UIKit
import GoogleSignIn
import CoreData
class ViewController: UIViewController, GIDSignInDelegate {
    @IBOutlet weak var signInButton: GIDSignInButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        signInButton?.layer.cornerRadius = 10
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.delegate = self
    }
    
    @IBAction func googleSignIn(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    func getManagedObjectContext() -> NSManagedObjectContext? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
        else {
            return nil
        }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        return managedObjectContext
    }
    
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("The user has not signed in before or they have since signed out.")
            } else {
                print("\(error.localizedDescription)")
            }
            return
        }
        let email = user.profile.email
        if !(email?.contains(Constants.MONASH_EMAIL_DOMAIN))! {
            signOut()
            showAlert(title: "Error", message: "Please use a valid Monash email address to login", actionTitle: "Ok")
            return
        }
        let firstName = user.profile.givenName
        let lastName = user.profile.familyName
        let userId = user.userID
        let userDefaults = UserDefaults.standard
        let managedObjectContext = getManagedObjectContext()
        let loggedInUser = LoggedInUser(context: managedObjectContext!)
        loggedInUser.email = email
        loggedInUser.firstName = firstName
        loggedInUser.lastName = lastName
        loggedInUser.userId = userId
        do {
            try managedObjectContext?.save()
            userDefaults.set(true, forKey: Constants.USER_LOGGED_IN_DEFAULT_KEY)
            let mainstoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let home = mainstoryboard.instantiateViewController(withIdentifier: Constants.USER_CHAT_ROOM_VIEW_STRORYBOARD_ID) as! UserChatRoomsTableViewController
            self.navigationController?.pushViewController(home, animated: true)
        } catch let error as NSError {
            print("ERROR IN LOGIN \(error.localizedDescription)")
        }
    }
    
    func showAlert(title: String, message: String, actionTitle: String) {
        let alertAction = UIAlertAction(title: actionTitle, style: .default, handler: nil)
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
    }
    
    func signOut() {
        GIDSignIn.sharedInstance()?.signOut()
    }
}

