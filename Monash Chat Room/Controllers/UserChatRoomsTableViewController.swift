//
//  UserChatRoomsTableViewController.swift
//  Monash Chat Room
//
//  Created by Kshitij Pandey on 14/10/20.
//

import UIKit

class UserChatRoomsTableViewController: UITableViewController, UISearchBarDelegate, UITextFieldDelegate, UISearchResultsUpdating {
    
    var userChatRooms: [ChatRoomDetail] = []
    var filteredChatRooms: [ChatRoomDetail] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        SocketHelper.shared.connectToSocket()
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
    
}
