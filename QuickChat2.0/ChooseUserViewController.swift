//
//  ChooseUserViewController.swift
//  QuickChat2.0
//
//  Created by David Kababyan on 09/10/2016.
//  Copyright © 2016 David Kababyan. All rights reserved.
//

import UIKit

class ChooseUserViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {
    
    let searchController = UISearchController(searchResultsController: nil)
    var users: [FUser] = []
    var filteredUsers: [FUser] = []
    
    @IBOutlet weak var tableView: UITableView!
    
        

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        
        tableView.tableHeaderView = searchController.searchBar
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backArrow"), style: .plain, target: self, action: #selector(ChooseUserViewController.backAction))

        
        loadUsers()
    }
    


    //MARK: TableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            
            return filteredUsers.count
            
        }
        
        return users.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! FriendTableViewCell
        
        var friend: FUser
        
        if searchController.isActive && searchController.searchBar.text != "" {
            
            friend = filteredUsers[indexPath.row]
            
        } else {
            
            friend = users[indexPath.row]
        }
        
        cell.bindData(friend: friend)
        
        return cell
        
    }
    
    //MARK: TablevieDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let user: FUser
        
        if searchController.isActive && searchController.searchBar.text != "" {
            
            user = filteredUsers[indexPath.row]
            
        } else {
            
            user = users[indexPath.row]
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let chatVC = ChatViewController()
        
        chatVC.titleName = user.firstname as String
        chatVC.members = [FUser.currentUser()!.objectId, user.objectId as String]
        chatVC.chatRoomId = startChat(user1: FUser.currentUser()!, user2: user)
        chatVC.isGroup = false

        chatVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    func backAction() {
        
        self.navigationController?.popViewController(animated: true)
    }

    
    //MARK: Load Users
    
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
    
    

    //MARK: SearchController functions
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        
        filteredUsers = users.filter({ (user) -> Bool in
            return user.firstname.lowercased().contains(searchText.lowercased())
        })
                
        tableView.reloadData()
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
    

    


}
