//
//  UserChatRoomsTableViewController.swift
//  Monash Chat Room
//
//  Created by Kshitij Pandey on 14/10/20.
//

import UIKit
import CoreData

class UserChatRoomsTableViewController: UITableViewController, UISearchBarDelegate, UITextFieldDelegate, UISearchResultsUpdating {
    
    var userChatRooms: [ChatRoomDetail] = []
    var filteredChatRooms: [ChatRoomDetail] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search by Name or Tag"
        navigationItem.searchController = searchController
        for n in 1...10 {
            let chatRoom = ChatRoomDetail(id: "\(n)", name: "Room \(n)", tag: "units", createdBy: "kpan0021@student.monash.edu", createdAt: "Today")
            userChatRooms.append(chatRoom)
        }
        filteredChatRooms = userChatRooms
        tableView.tableFooterView = UIView()
        fetchUserChatRooms()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filteredChatRooms.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.USER_CHAT_ROOMS_CELL_VIEW_IDENTIFIER, for: indexPath) as UITableViewCell
        
        cell.textLabel?.text = filteredChatRooms[indexPath.row].name
        cell.detailTextLabel?.text = filteredChatRooms[indexPath.row].tag
        return cell
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else {
            return
        }
        let searchTextLowercased = searchText.lowercased()
        searchController.resignFirstResponder()
        if(searchText.count > 0) {
            filteredChatRooms = userChatRooms.filter({ (room: ChatRoomDetail) -> Bool in
                return (room.name.lowercased().contains(searchTextLowercased) || (room.tag.lowercased().contains(searchTextLowercased)))
            })
        }
        else {
            filteredChatRooms = userChatRooms
        }
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Constants.USER_CHAT_ROOMS_TO_CHAT_ROOM_SEGUE_IDENTIFIER, sender: self)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.USER_CHAT_ROOMS_TO_CHAT_ROOM_SEGUE_IDENTIFIER {
            let destination = segue.destination as! ChatRoomController
        }
    }
    
    func getManagedobjectContext() -> NSManagedObjectContext? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
        else {
            return nil
        }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        return managedObjectContext
    }
    
    func fetchLoggedInUserData() -> [LoggedInUser]? {
        let managedObjectContext = getManagedobjectContext()
        if managedObjectContext != nil {
            let fetchRequest = NSFetchRequest<LoggedInUser>(entityName: "LoggedInUser")
            do {
                let user = try managedObjectContext!.fetch(fetchRequest)
                return user
            } catch {
                return nil
            }
        }
        else {
            return nil
        }
    }
    
    func fetchUserChatRooms() {
        let loggedInUser: [LoggedInUser] = fetchLoggedInUserData()!
        if loggedInUser.count > 0 {
            let user: LoggedInUser = loggedInUser.first!
            let email = user.email
            print("EMAIL: \(String(describing: email))")
            print("FIRST NAME: \(String(describing: user.firstName))")
        }
        else {
            showAlert(title: "Error", message: "Could not fetch your chat rooms! PLease try again.", actionTitle: "Ok")
        }
    }
    
    func showAlert(title: String, message: String, actionTitle: String) {
        let alertAction = UIAlertAction(title: actionTitle, style: .default, handler: nil)
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
    }
    
}
