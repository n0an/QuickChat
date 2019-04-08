//
//  FriendsViewController.swift
//  QuickChat2.0
//
//  Created by David Kababyan on 23/10/2016.
//  Copyright © 2016 David Kababyan. All rights reserved.
//

import UIKit

class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, AddFriendDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var friendId: [String] = []
    
    var friends: [FUser] = []
    let searchController = UISearchController(searchResultsController: nil)
    var filteredFriends: [FUser] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        firebase.child(kUSER).removeAllObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        loadFriends()
    }
    

    
    //MARK: IBAction
    
    @IBAction func addFriendBarButtonItemPressed(_ sender: AnyObject) {
        
        performSegue(withIdentifier: "friendToAddFriendSeg", sender: self)
        
    }
    
    //MARK: TableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            
            return filteredFriends.count
        }
        
        return friends.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! FriendTableViewCell
        
        var friend: FUser
        
        if searchController.isActive && searchController.searchBar.text != "" {
            
            friend = filteredFriends[indexPath.row]
        } else {
            
            friend = friends[indexPath.row]
        }
        
        cell.bindData(friend: friend)
        
        return cell
    }
    

    
    //MARK: TableViewDelegate functions
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        let friend = friends[indexPath.row]
        
        friends.remove(at: indexPath.row)
        friendId.remove(at: indexPath.row)
        
        deleteFriend(friend: friend)
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        var friend: FUser
        
        if searchController.isActive && searchController.searchBar.text != "" {
            
            friend = filteredFriends[indexPath.row]
        } else {
            
            friend = friends[indexPath.row]
        }
        

        let chatVC = ChatViewController()
        
        chatVC.titleName = friend.firstname as String
        chatVC.members = [FUser.currentUser()!.objectId, friend.objectId as String]
        chatVC.chatRoomId = startChat(user1: FUser.currentUser()!, user2: friend)
        chatVC.isGroup = false

        chatVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(chatVC, animated: true)
        
    }

    
    func loadFriends() {
        
        cleanup()
        
        //get the friends of current user
        let friendIds = FUser.currentUser()!.friends
        
        if friendIds.count > 0 {

            //go through each friend and download it from firebase
            for friendId in friendIds {
                
                firebase.child(kUSER).queryOrdered(byChild: kOBJECTID).queryEqual(toValue: friendId).observeSingleEvent(of: .value, with: {
                    snapshot in
                    
                    if snapshot.exists() {
                        
                        let userDictionary = ((snapshot.value as! NSDictionary).allValues as Array).first
                        
                        let fUser = FUser.init(_dictionary: userDictionary as! NSDictionary)
                        
                        self.friends.append(fUser)
                        self.friendId.append(fUser.objectId)
                        
                    }
                    
                    self.tableView.reloadData()
                })
                
                
            }

        } else {
            ProgressHUD.showError("Currently you have no friends :(, Please add some")
            print("No friends")
        }

    }
    
    
    //MARK: Helper functions
    
    func cleanup() {
        
        friendId.removeAll()
        friends.removeAll()
        tableView.reloadData()
    }
    
    
    //MARK: search controler functions
    
    func filteredContentForSearchText(searchText: String, scope: String = "All") {
        
        filteredFriends = friends.filter({ (friend) -> Bool in
            
            return friend.firstname.lowercased().contains(searchText.lowercased())

        })
        
        tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        filteredContentForSearchText(searchText: searchController.searchBar.text!)
    }

    
    //MARK: AddFriend delegate functions
    
    func saveFriend(selectedFriend: FUser) {
        
        if friendId.contains(selectedFriend.objectId as String) {
            
            return
        }
        
        //get current friends
        var currentFriends = FUser.currentUser()!.friends
        
        currentFriends.append(selectedFriend.objectId)
        
        let newDate = dateFormatter().string(from: Date())
        
        updateUser(withValues: [kFRIEND : currentFriends, kUPDATEDAT : newDate]) { (success) in
            
            self.loadFriends()
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "friendToAddFriendSeg" {
            
            let vc = segue.destination as! AddFriendViewController
            vc.delegate = self
            
            vc.hidesBottomBarWhenPushed = true
        }
        
    }
    
    //MARK: DeleteFriend
    
    func deleteFriend(friend: FUser) {
        
        var currentFriends = FUser.currentUser()!.friends
        
        let indexOfFriend = currentFriends.index(of: friend.objectId)
        
        currentFriends.remove(at: indexOfFriend!)
        
        let newDate = dateFormatter().string(from: Date())

        updateUser(withValues: [kFRIEND : currentFriends, kUPDATEDAT : newDate]) { (success) in
            
            self.loadFriends()
            
        }
        
    }
    

    


}
