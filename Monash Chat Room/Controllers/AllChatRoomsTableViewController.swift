//
//  AllChatRoomsTableViewController.swift
//  Monash Chat Room
//
//  Created by Kshitij Pandey on 14/10/20.
//

import UIKit

class AllChatRoomsTableViewController: UITableViewController, UISearchBarDelegate, UITextFieldDelegate, UISearchResultsUpdating, SocketConnectionDelegate {
    
    var allChatRooms:ChatRooms?
    var filteredChatRooms: [ChatRoomDetails]?
    var loggedInUserEmail: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        let socketHelper = SocketHelper()
        socketHelper.delegate = self
        socketHelper.connectToSocket()
        let userDefault = UserDefaults.standard
        loggedInUserEmail = userDefault.string(forKey: Constants.LOGGED_IN_USER_EMAIL_KEY)
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search by Name or Tag"
        navigationItem.searchController = searchController
        tableView.tableFooterView = UIView()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        var numberOfSections = 0
        if filteredChatRooms?.count ?? 0 > 0 {
            numberOfSections = 1
        }
        else {
            let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.numberOfLines = 0
            noDataLabel.text = Constants.NO_ROOMS_LABEL
            noDataLabel.textColor = Constants.LABEL_COLOR
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        return numberOfSections
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredChatRooms?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.ALL_CHAT_ROOMS_CELL_VIEW_IDENTIFIER, for: indexPath) as UITableViewCell
        
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
            filteredChatRooms = allChatRooms?.rooms.filter({ (room: ChatRoomDetails) -> Bool in
                return (room.name.lowercased().contains(searchTextLowercased) || (room.tag.lowercased().contains(searchTextLowercased)))
            })
        }
        else {
            filteredChatRooms = allChatRooms?.rooms
        }
        tableView.reloadData()
    }
    
    func emitFetchAllRoomsEvent() {
        SocketHelper.Events.fetchAllRooms.emit(params: ["userId" : loggedInUserEmail])
    }
    
    func initalizeAllRoomsListeners() {
        SocketHelper.Events.fetchAllRooms.listen { (data) in
            do {
                if let arr = data as? [[String: Any]] {
                    let roomDataJson = try JSONSerialization.data(withJSONObject: arr[0])
                    let roomsData = try JSONDecoder().decode(ChatRooms.self, from: roomDataJson)
                    if roomsData.userId == self.loggedInUserEmail {
                        self.allChatRooms = roomsData
                        self.filteredChatRooms = self.allChatRooms?.rooms
                        self.tableView.reloadData()
                    }
                }
            } catch let error {
                print("ERROR IN <><><><initalizeAllRoomsListeners \(error.localizedDescription)")
            }
        }
        
        SocketHelper.Events.fetchUserRoomsError.listen { (data) in
            if let arr = data as? [[String: Any]] {
                if let userId = arr[0]["userId"] as? String {
                    print("ERROR IN fetchUserRooms \(userId)")
                }
            }
        }
        emitFetchAllRoomsEvent()
    }
    
    func connectedToSocket(isConnected: Bool) {
        initalizeAllRoomsListeners()
    }
}
