//
//  AddFriendViewController.swift
//  QuickChat2.0
//
//  Created by David Kababyan on 23/10/2016.
//  Copyright © 2016 David Kababyan. All rights reserved.
//

import UIKit


protocol AddFriendDelegate {
    
    func saveFriend(selectedFriend: FUser)
}

class AddFriendViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {

    
    @IBOutlet weak var tableView: UITableView!
    
    var users: [FUser] = []
    
    var delegate: AddFriendDelegate!
    
    let searchController = UISearchController(searchResultsController: nil)
    var filteredUsers: [FUser] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadUsers()
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backArrow"), style: .plain, target: self, action: #selector(AddFriendViewController.backAction))

    
    }
    
    func backAction() {
        
        self.navigationController?.popViewController(animated: true)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: TableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            
            return filteredUsers.count
        } else {
            
            return users.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! FriendTableViewCell
        
        var user: FUser
        
        if searchController.isActive && searchController.searchBar.text != "" {
            
            user = filteredUsers[indexPath.row]
        } else {
            
            user = users[indexPath.row]
        }
        
        cell.bindData(friend: user)
        
        
        return cell
    }
    
    
    //MARK: TableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let user: FUser
        
        if searchController.isActive && searchController.searchBar.text != "" {
            
            user = filteredUsers[indexPath.row]
        } else {
            
            user = users[indexPath.row]
        }
        
        delegate.saveFriend(selectedFriend: user)
        tableView.deselectRow(at: indexPath, animated: true)
        self.navigationController!.popViewController(animated: true)
    }
    
    //MARK: LoadUsers
    
    func loadUsers() {
        
        
        firebase.child(kUSER).queryOrdered(byChild: kFIRSTNAME).observe(.value, with: {
            snapshot in
            
            self.users.removeAll()
            
            if snapshot.exists() {
                
                let sortedUsersDictionary = ((snapshot.value as! NSDictionary).allValues as NSArray).sortedArray(using: [NSSortDescriptor(key: kFIRSTNAME, ascending: true)])
                
                for userDictionary in sortedUsersDictionary {
                    
                    let userDictionary = userDictionary as! NSDictionary
                    let fUser = FUser.init(_dictionary: userDictionary)
                    
                    if fUser.objectId != FUser.currentUser()!.objectId {
                        
                        self.users.append(fUser)
                        
                    }
                    
                }
                
            }
            
            self.tableView.reloadData()
            
        })
        
    }
    
    //MARK: search controler functions
    
    func filteredContentForSearchText(searchText: String, scope: String = "All") {
        
        filteredUsers = users.filter({ (user) -> Bool in
            
            return user.firstname.lowercased().contains(searchText.lowercased())

        })
            
        tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        filteredContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
    

}
