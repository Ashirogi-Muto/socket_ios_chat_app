//
//  AllChatRoomsTableViewController.swift
//  Monash Chat Room
//
//  Created by Kshitij Pandey on 14/10/20.
//

import UIKit

/**
 Class to manage all the chat rooms available in the app
 */
class AllChatRoomsTableViewController: UITableViewController, UISearchBarDelegate, UITextFieldDelegate, UISearchResultsUpdating {
    
    var allChatRooms: [ChatRoomDetails]?
    var filteredChatRooms: [ChatRoomDetails]?
    var loggedInUserEmail: String?
    var selectedChatRoom: ChatRoomDetails?
    var indicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let userDefault = UserDefaults.standard
        loggedInUserEmail = userDefault.string(forKey: Constants.LOGGED_IN_USER_EMAIL_KEY)
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search by Name or Tag"
        navigationItem.searchController = searchController
        tableView.tableFooterView = UIView()
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.center = view.center
        indicator.hidesWhenStopped = true
        indicator.backgroundColor = UIColor.clear
        view.addSubview(indicator)
        indicator.startAnimating()
        fetchAllChatRooms()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        var numberOfSections = 0
        if filteredChatRooms?.count ?? 0 > 0 {
            numberOfSections = 1
        }
        return numberOfSections
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredChatRooms?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.ALL_CHAT_ROOMS_CELL_VIEW_IDENTIFIER, for: indexPath) as! ChatRoomTableViewCell
        cell.roomLabel?.text = filteredChatRooms![indexPath.row].name
        cell.descriptionLabel?.text = filteredChatRooms![indexPath.row].tag
        
        cell.containerView.layer.cornerRadius = 10.0;
        cell.containerView.layer.borderColor = UIColor.black.cgColor;
        cell.containerView.layer.shadowOffset = CGSize(width: 0 , height:2)
        cell.containerView.layer.shadowRadius = 5.0;
        cell.containerView.layer.shadowOpacity = 0.4;
        cell.borderView.layer.cornerRadius = 10.0;
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedChatRoom = filteredChatRooms![indexPath.row]
        performSegue(withIdentifier: Constants.ALL_ROOMS_TO_CHAT_ROOM_SEGUE_IDENTIFIER, sender: self)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else {
         return
         }
        let searchTextLowercased = searchText.lowercased()
        searchController.resignFirstResponder()
        if(searchText.count > 0) {
            filteredChatRooms = allChatRooms!.filter({ (room: ChatRoomDetails) -> Bool in
                return (room.name.lowercased().contains(searchTextLowercased) || (room.tag.lowercased().contains(searchTextLowercased)))
            })
        }
        else {
            filteredChatRooms = allChatRooms!
        }
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.ALL_ROOMS_TO_CHAT_ROOM_SEGUE_IDENTIFIER {
            let destination = segue.destination as! ChatRoomController
            destination.selectedRoomDetails = selectedChatRoom
        }
          
    }
    
    /**
     Fetch all the chat rooms available in the app
     */
    func fetchAllChatRooms() {
        let url = Constants.SOCKET_URL + Constants.FETCH_ALL_ROOMS_API_ROUTE
        let finalUrl = URL(string: url)
        let task = URLSession.shared.dataTask(with: finalUrl!) { (data, response, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.indicator.stopAnimating()
                    self.showAlert(title: "Error", message: "Could not fetch all the rooms! Please try again.", actionTitle: "Ok")
                }
                return
            }
            if let safeData = data {
                let decoder = JSONDecoder()
                do {
                    let responseData = try decoder.decode(FetchRoomsAPIResponse.self, from: safeData)
                    DispatchQueue.main.async {
                        self.allChatRooms = responseData.result.rooms
                        self.filteredChatRooms = self.allChatRooms
                        self.indicator.stopAnimating()
                        self.tableView.reloadData()
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.indicator.stopAnimating()
                        self.showAlert(title: "Error", message: "Could not fetch all the rooms! Please try again.", actionTitle: "Ok")
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
