//
//  UserChatRoomsTableViewController.swift
//  Monash Chat Room
//
//  Created by Kshitij Pandey on 14/10/20.
//

import UIKit
import CoreData

class UserChatRoomsTableViewController: UITableViewController, UISearchBarDelegate, UITextFieldDelegate, UISearchResultsUpdating {
    var userChatRooms: [ChatRoomDetails]?
    var filteredChatRooms: [ChatRoomDetails]?
    var loggedInUserEmail: String?
    var selectedChatRoom: ChatRoomDetails?
    var indicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SocketHelper.shared.connectToSocket()
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search by Name or Tag"
        navigationItem.searchController = searchController
        tableView.tableFooterView = UIView()
        let userDefault = UserDefaults.standard
        loggedInUserEmail = userDefault.string(forKey: Constants.LOGGED_IN_USER_EMAIL_KEY)
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.center = view.center
        indicator.hidesWhenStopped = true
        indicator.backgroundColor = UIColor.clear
        view.addSubview(indicator)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        indicator.startAnimating()
        fetchUserChatRooms()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if filteredChatRooms?.count ?? -1 > 0 {
            return 1
        }
        return 0
//        else {
//            let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
//            noDataLabel.text = Constants.NO_USER_CHAT_ROOM_LABEL
//            noDataLabel.textColor = Constants.LABEL_COLOR
//            noDataLabel.textAlignment = .center
//            tableView.backgroundView  = noDataLabel
//            tableView.separatorStyle  = .none
//            return 0
//        }
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
            filteredChatRooms = userChatRooms!.filter({ (room: ChatRoomDetails) -> Bool in
                return (room.name.lowercased().contains(searchTextLowercased) || (room.tag.lowercased().contains(searchTextLowercased)))
            })
        }
        else {
            filteredChatRooms = userChatRooms!
        }
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedChatRoom = filteredChatRooms![indexPath.row]
        performSegue(withIdentifier: Constants.USER_CHAT_ROOMS_TO_CHAT_ROOM_SEGUE_IDENTIFIER, sender: self)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let selectedRoom = filteredChatRooms![indexPath.row]
            removeUserFromRoom(id: selectedRoom.id)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
         return "Leave Room"
    }
    
    func removeUserFromRoom(id: String) {
        indicator.startAnimating()
        let url = Constants.SOCKET_URL + Constants.LEAVE_ROOM_API_ROUTE + "/" + id
        let urlWithQuery = url + "?userEmail=" + loggedInUserEmail!
        let finalUrl = URL(string: urlWithQuery)
        var request = URLRequest(url: finalUrl!)
        request.httpMethod = "POST"

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print(error?.localizedDescription)
                DispatchQueue.main.async {
                    self.indicator.stopAnimating()
                    self.showAlert(title: "Oop!", message: "Could not remove you from this room! Please try again.", actionTitle: "Ok")
                }
            }
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("DATA \(dataString)")
                DispatchQueue.main.async {
                    self.indicator.stopAnimating()
                    self.fetchUserChatRooms()
                }
            }
            
        }
        task.resume()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.USER_CHAT_ROOMS_TO_CHAT_ROOM_SEGUE_IDENTIFIER {
            let destination = segue.destination as! ChatRoomController
            destination.selectedRoomDetails = selectedChatRoom
        }
    }

    func fetchUserChatRooms() {
        let url = Constants.SOCKET_URL + Constants.FETCH_USER_ROOMS_API_ROUTE + "/" + loggedInUserEmail!
        let finalUrl = URL(string: url)
        let task = URLSession.shared.dataTask(with: finalUrl!) { (data, response, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.indicator.stopAnimating()
                    self.showAlert(title: "Error", message: "Could not fetch your rooms! PLease try again.", actionTitle: "Ok")
                }
                return
            }
            if let safeData = data {
                let decoder = JSONDecoder()
                do {
                    let responseData = try decoder.decode(FetchRoomsAPIResponse.self, from: safeData)
                    DispatchQueue.main.async { [self] in
                        self.userChatRooms = responseData.result.rooms
                        self.filteredChatRooms = self.userChatRooms
                        let allRoomIds: [String] = (self.userChatRooms?.map{ $0.id })!
                        let defaults = UserDefaults.standard
                        defaults.set(allRoomIds, forKey: Constants.USER_ROOMS_IDS_KEY)
                        self.indicator.stopAnimating()
                        self.tableView.reloadData()
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.indicator.stopAnimating()
                        self.showAlert(title: "Error", message: "Could not fetch your rooms! PLease try again.", actionTitle: "Ok")
                    }
                }
            }
        }
        task.resume()
    }
    
    func showAlert(title: String, message: String, actionTitle: String) {
        let alertAction = UIAlertAction(title: actionTitle, style: .default, handler: nil)
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
    }
    
}
