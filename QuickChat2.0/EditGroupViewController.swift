//
//  EditGroupViewController.swift
//  QuickChat2.0
//
//  Created by David Kababyan on 05/11/2016.
//  Copyright © 2016 David Kababyan. All rights reserved.
//

import UIKit

protocol EditGroupDelegate {
    
    func finishedEditingGroup(updatedGroup: NSDictionary)
}

class EditGroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    var delegate: EditGroupDelegate!
    
    var group: NSDictionary?
    var groupMembers: [String] = []
    var friends: [FUser] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()

        groupMembers = (group![kMEMBERS] as? [String])!
        
        
        loadFriend()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    
    //MARK: TableView data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return friends.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FriendTableViewCell
        
        let user = friends[indexPath.row]
        
        cell.accessoryType = .none
        
        cell.bindData(friend: user)
        
        return cell
    }
    
    
    //MARK: TableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let cell = tableView.cellForRow(at: indexPath) {
            
            
            if cell.accessoryType == .checkmark {
                
                cell.accessoryType = .none
            } else {
                
                cell.accessoryType = .checkmark
            }
            
        }
        
        
        let selectedUser = friends[indexPath.row]
        
        let selected = groupMembers.contains(selectedUser.objectId as String)
        
        
        if selected {
            
            let objectIndex = groupMembers.index(of: selectedUser.objectId as String)
            groupMembers.remove(at: objectIndex!)
            
        } else {
            
            groupMembers.append(selectedUser.objectId as String)
        }
        
    }
    

    



    //MARK: IBActions
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        
        let groupId = group![kGROUPID] as? String
        let values = [kMEMBERS : groupMembers]
        
        firebase.child(kGROUP).child(groupId!).updateChildValues(values)
        
        updateMembersInRecent(members: groupMembers, group: group!)
        
        group!.setValue(groupMembers, forKey: kMEMBERS)
        delegate.finishedEditingGroup(updatedGroup: group!)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: Load friends
    
    func loadFriend() {
        
        cleanup()
        
        //get the friends of current user
        let friendIds = FUser.currentUser()!.friends
        
        if friendIds.count > 0 {
            
            //go through each friend and download it from firebase
            for friendId in friendIds {
                
                firebase.child(kUSER).queryOrdered(byChild: kOBJECTID).queryEqual(toValue: friendId).observe(.value, with: {
                    snapshot in
                    
                    if snapshot.exists() {
                        
                        let userDictionary = ((snapshot.value as! NSDictionary).allValues as Array).first
                        
                        let fUser = FUser.init(_dictionary: userDictionary as! NSDictionary)
                        
                        //if the friend is not in the group, add to array
                        if !(self.group![kMEMBERS] as? [String])!.contains(fUser.objectId) {
    
                            self.friends.append(fUser)
                        }
                        
                    }
                    
                    self.tableView.reloadData()
                })
                
                
            }
            
        } else {
            
            print("No friends")
        }

        
    }
    
    func cleanup() {
        
        friends.removeAll()
        tableView.reloadData()
    }

    

}
