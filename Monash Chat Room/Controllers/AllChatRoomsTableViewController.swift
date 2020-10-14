//
//  AllChatRoomsTableViewController.swift
//  Monash Chat Room
//
//  Created by Kshitij Pandey on 14/10/20.
//

import UIKit

class AllChatRoomsTableViewController: UITableViewController, UISearchBarDelegate, UITextFieldDelegate, UISearchResultsUpdating {
    
    var allChatRooms: [ChatRoomDetail] = []
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
            allChatRooms.append(chatRoom)
        }
        filteredChatRooms = allChatRooms
        tableView.tableFooterView = UIView()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.ALL_CHAT_ROOMS_CELL_VIEW_IDENTIFIER, for: indexPath) as UITableViewCell
        
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
            filteredChatRooms = allChatRooms.filter({ (room: ChatRoomDetail) -> Bool in
                return (room.name.lowercased().contains(searchTextLowercased) || (room.tag.lowercased().contains(searchTextLowercased)))
            })
        }
        else {
            filteredChatRooms = allChatRooms
        }
        tableView.reloadData()
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */

}
