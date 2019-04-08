//
//  RecentViewController.swift
//  QuickChat2.0
//
//  Created by David Kababyan on 09/10/2016.
//  Copyright © 2016 David Kababyan. All rights reserved.
//

import UIKit

class RecentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var tableView: UITableView!
    
    var recents: [NSDictionary] = []
    
    var firsrLoad: Bool?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadRecents()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    //MARK: UITableviewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return recents.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! RecentTableViewCell
        
        let recent = recents[indexPath.row]
        
        cell.bindData(recent: recent)
        
        return cell
    }
    
    
    //MARK: UITableview Delegate
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        let recent = recents[indexPath.row]
        
        if (recent[kTYPE] as? String)! == kGROUP {
            
            recentDeleteWarning(indexPath: indexPath)
            
        } else {
            
            recents.remove(at: indexPath.row)
            
            deleteRecentItem(recentID: (recent[kRECENTID] as? String)!)
            
            tableView.reloadData()
        }
        
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let recent = recents[indexPath.row]
        
        restartRecentChat(recent: recent)
        
        let chatVC = ChatViewController()
        
        chatVC.hidesBottomBarWhenPushed = true
        chatVC.titleName = (recent[kWITHUSERUSERNAME] as? String)!
        chatVC.members = (recent[kMEMBERS] as? [String])!
        chatVC.chatRoomId = (recent[kCHATROOMID] as? String)!
//        chatVC.isGroup = false
        
        if (recent[kTYPE] as? String)! == kGROUP {
            
            chatVC.isGroup = true
        }
        
        navigationController?.pushViewController(chatVC, animated: true)
        
    }


    

    //MARK: IBAction

    @IBAction func addRecentBarButtonPressed(_ sender: AnyObject) {
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let friendList = UIAlertAction(title: "Friend List", style: .default) { (alert: UIAlertAction!) in
            
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RecentVC") as! UITabBarController
            
            vc.selectedIndex = 2
            
            self.present(vc, animated: true, completion: nil)
        }
        
        let allUsers = UIAlertAction(title: "All users", style: .default) { (alert: UIAlertAction!) in
            
            self.performSegue(withIdentifier: "recentToChooseUserSeg", sender: self)
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert: UIAlertAction!) in
            
        }
        
        optionMenu.addAction(friendList)
        optionMenu.addAction(allUsers)
        optionMenu.addAction(cancelAction)

        self.present(optionMenu, animated: true, completion: nil)
        
    }
    
    
    //MARK: Load Recents
    
    func loadRecents() {
        
        firebase.child(kRECENT).queryOrdered(byChild: kUSERID).queryEqual(toValue: FUser.currentUser()!.objectId).observe(.value, with: {
            snapshot in
            
            self.recents.removeAll()
            
            if snapshot.exists() {
                
                let sorted = ((snapshot.value as! NSDictionary).allValues as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: false)])
                
                
                for recent in sorted {
                    
                    let currentRecent = recent as! NSDictionary
                    
                    self.recents.append(currentRecent)
                    
                    
                    firebase.child(kRECENT).queryOrdered(byChild: kCHATROOMID).queryEqual(toValue: currentRecent[kCHATROOMID]).observe(.value, with: {
                        snapshot in
                        
                    })
                    
                }
                
            }
            
            self.tableView.reloadData()
            
        })
        
    }
    
    
    //MARK: Helper functions
    
    func recentDeleteWarning(indexPath: IndexPath) {
        
        let alertController = UIAlertController(title: "Attention!", message: "Would you like to receive notofications from this group?", preferredStyle: .alert)
        
        let recent = recents[indexPath.row]
        
        recents.remove(at: indexPath.row)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (acation: UIAlertAction!) in
            
            deleteRecentItem(recentID: (recent[kRECENTID] as? String)!)
            
            self.tableView.reloadData()
        }
        
        let noAction = UIAlertAction(title: "No", style: .destructive) { (acation: UIAlertAction!) in
            
            deleteRecentWithNotification(recent: recent)
            
            self.tableView.reloadData()
            
        }
        
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        
        
        self.present(alertController, animated: true, completion: nil)
    }
    

    


    
    
}
