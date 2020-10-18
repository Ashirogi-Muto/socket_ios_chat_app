//
//  UserChatRoomsTableViewController.swift
//  Monash Chat Room
//
//  Created by Kshitij Pandey on 14/10/20.
//

import UIKit
import CoreData

class UserChatRoomsTableViewController: UITableViewController, UISearchBarDelegate, UITextFieldDelegate, UISearchResultsUpdating, SocketConnectionDelegate {
    var userChatRooms: ChatRooms?
    var filteredChatRooms: [ChatRoomDetails]?
    var loggedInUserEmail: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let socketHelper = SocketHelper()
        socketHelper.delegate = self
        socketHelper.connectToSocket()
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search by Name or Tag"
        navigationItem.searchController = searchController
        tableView.tableFooterView = UIView()
        let userDefault = UserDefaults.standard
        loggedInUserEmail = userDefault.string(forKey: Constants.LOGGED_IN_USER_EMAIL_KEY)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        var numberOfSections = 0
        if filteredChatRooms?.count ?? 0 > 0 {
            numberOfSections = 1
        }
        else {
            let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text = Constants.NO_USER_CHAT_ROOM_LABEL
            noDataLabel.textColor = Constants.LABEL_COLOR
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        return numberOfSections
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filteredChatRooms!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.USER_CHAT_ROOMS_CELL_VIEW_IDENTIFIER, for: indexPath) as UITableViewCell
        
        cell.textLabel?.text = filteredChatRooms![indexPath.row].name
        cell.detailTextLabel?.text = filteredChatRooms![indexPath.row].tag
        return cell
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else {
            return
        }
        let searchTextLowercased = searchText.lowercased()
        searchController.resignFirstResponder()
        if(searchText.count > 0) {
            filteredChatRooms = userChatRooms!.rooms.filter({ (room: ChatRoomDetails) -> Bool in
                return (room.name.lowercased().contains(searchTextLowercased) || (room.tag.lowercased().contains(searchTextLowercased)))
            })
        }
        else {
            filteredChatRooms = userChatRooms?.rooms
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
    
    func emitFetchUserRoomsEvent() {
        print("EMITTING FETCH USER ROOMS")
        SocketHelper.Events.fetchUserRooms.emit(params: ["userId" : loggedInUserEmail])
    }
    
    func initalizeUserChatRoomsListener() {
        SocketHelper.Events.fetchUserRooms.listen { (data) in
            do {
                if let arr = data as? [[String: Any]] {
                    let roomDataJson = try JSONSerialization.data(withJSONObject: arr[0])
                    let roomsData = try JSONDecoder().decode(ChatRooms.self, from: roomDataJson)
                    if roomsData.userId == self.loggedInUserEmail {
                        self.userChatRooms = roomsData
                        self.filteredChatRooms = self.userChatRooms?.rooms
                        self.tableView.reloadData()
                    }
                }
            } catch let error {
                print("ERROR IN <><><>< \(error.localizedDescription)")
            }
        }
        
        SocketHelper.Events.fetchUserRoomsError.listen { (data) in
            if let arr = data as? [[String: Any]] {
                if let userId = arr[0]["userId"] as? String {
                    print("ERROR IN fetchUserRooms \(userId)")
                }
            }
        }
        emitFetchUserRoomsEvent()
    }
    
    func showAlert(title: String, message: String, actionTitle: String) {
        let alertAction = UIAlertAction(title: actionTitle, style: .default, handler: nil)
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
    }
    
    func connectedToSocket(isConnected: Bool) {
        initalizeUserChatRoomsListener()
    }
    
}
