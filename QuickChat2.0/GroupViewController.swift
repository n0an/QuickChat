//
//  GroupViewController.swift
//  QuickChat2.0
//
//  Created by David Kababyan on 29/10/2016.
//  Copyright © 2016 David Kababyan. All rights reserved.
//

import UIKit

class GroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var groups: [NSDictionary] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()


        loadGroups()
    }

    //MARK: TableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! GroupNameTableViewCell
        
        let group = groups[indexPath.row]
        cell.bindData(group: group, withMembers: true)
        
        return cell
    }
    
    //MARK: TableViewDelagte functions
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        performSegue(withIdentifier: "groupToGroupSettingsSeg", sender: indexPath)
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        groupDeleteWarning(indexPath: indexPath)
        
    }
    
    //MARK: Load Groups
    
    func loadGroups() {
        
        firebase.child(kGROUP).queryOrdered(byChild: kOWNERID).queryEqual(toValue: FUser.currentUser()!.objectId).observe(.value, with: {
            snapshot in
            
            self.groups.removeAll()
            
            if snapshot.exists() {
                
                let sorted = ((snapshot.value! as! NSDictionary).allValues as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: false)])
                
                
                for group in sorted {
                    
                    self.groups.append(group as! NSDictionary)
                }
            }
            
            self.tableView.reloadData()
            
        })
        
        
    }
    
    
    //MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "groupToAddGroupSeg" {
            
            let vc = segue.destination as! AddGroupViewController
            
            vc.hidesBottomBarWhenPushed = true
        }
        
        if segue.identifier == "groupToGroupSettingsSeg" {
            
            let indexPath = sender as! NSIndexPath
            
            let vc = segue.destination as! GroupSettingsViewController
            
            vc.group = self.groups[indexPath.row]
        }
        
        
    }
    


    

    
    
    //MARK: IBActions
    
    @IBAction func addBarButtonItemPressed(_ sender: AnyObject) {
        
        performSegue(withIdentifier: "groupToAddGroupSeg", sender: self)
    }
    

    func groupDeleteWarning(indexPath: IndexPath) {
        
        let alertController = UIAlertController(title: "Warning!!!", message: "This will delete all group messages!", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action: UIAlertAction!) in
            
        }
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action: UIAlertAction!) in
            
            let group = self.groups[indexPath.row]
            self.groups.remove(at: indexPath.row)
            
            Group.deleteGroup(groupId: (group[kGROUPID] as? String)!)
            
            self.tableView.reloadData()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    


}
