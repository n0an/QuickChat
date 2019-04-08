//
//  AddGroupViewController.swift
//  QuickChat2.0
//
//  Created by David Kababyan on 29/10/2016.
//  Copyright © 2016 David Kababyan. All rights reserved.
//

import UIKit

class AddGroupViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var groupNameTextField: UITextField!
    
    var friends: [FUser] = []
    var groupMembers: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableHeaderView = headerView
        

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backArrow"), style: .plain, target: self, action: #selector(AddGroupViewController.backAction))

        loadFriends()
    }
    
    func backAction() {
        
        self.navigationController?.popViewController(animated: true)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: IBActions
    @IBAction func doneBarButtonItemPressed(_ sender: AnyObject) {
        
        if groupNameTextField.text == "" {
            
            ProgressHUD.showError("Group name must be set!")
            return
        }
        
        if groupMembers.count == 0 {
            
            ProgressHUD.showError("Please select some users")
            return
        }
        
        groupMembers.append(FUser.currentUser()!.objectId)
                
        //ask for avatar
        showAvatarNotification()
        
        self.navigationController?.popViewController(animated: true)
    }

    
    //MARK: TableViewDatasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FriendTableViewCell
        
        cell.accessoryType = .none
        
        let user = friends[indexPath.row]

        cell.bindData(friend: user)
        
        return cell
    }
    
    //MARK: TableView Delegate
    
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
    
    
    //MARK: LoadUsers
    
    func loadFriends() {
        
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
                        
                        self.friends.append(fUser)
                        
                    }
                    
                    self.tableView.reloadData()
                })
                
                
            }
            
        } else {
            
            ProgressHUD.showError("Currently you have no friends :(, Please add some")
            print("No friends")
        }
        
    }

    
        func cleanup() {
        
        groupMembers.removeAll()
        friends.removeAll()
        tableView.reloadData()
    }

    
    //MARK: Group Avatra functions
    
    func showAvatarNotification() {
        
        let alertController = UIAlertController(title: "Avatar", message: "Would you like to add Avatar to your group?", preferredStyle: .alert)
        
        let noAction = UIAlertAction(title: "No", style: .cancel) { (action: UIAlertAction!) in
            
            //creat a group
            let group = Group(name: self.groupNameTextField.text!, ownerId: FUser.currentUser()!.objectId, members: self.groupMembers, avatar: "")
            
            Group.saveGroup(group: group.groupDictionary)
            
            self.navigationController?.popViewController(animated: true)
            
        }
        
        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { (action: UIAlertAction!) in
            
            self.showCameraOptions()
        }
        
        alertController.addAction(noAction)
        alertController.addAction(yesAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
    func showCameraOptions() {
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let camera = Camera(delegate_: self)
        
        let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { (alert: UIAlertAction!) in
            
            camera.PresentPhotoCamera(target: self, canEdit: true)
            
        }
        
        let sharePhoto = UIAlertAction(title: "Photo Library", style: .default) { (alert: UIAlertAction!) in
            
            camera.PresentPhotoLibrary(target: self, canEdit: true)
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert: UIAlertAction!) in
            
        }
        
        optionMenu.addAction(takePhoto)
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
        
    }
    
    //MARK: UIIMagepickercontroller delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let avatarImage = (info[UIImagePickerControllerEditedImage] as! UIImage)
        
        picker.dismiss(animated: true, completion: nil)
        saveGroupAvatar(avatarImage: avatarImage)

    }
    
    func saveGroupAvatar(avatarImage: UIImage) {
        
        let image = UIImageJPEGRepresentation(avatarImage, 0.5)
        
        let avatar = image!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))

        //creat a group
        let group = Group(name: self.groupNameTextField.text!, ownerId: FUser.currentUser()!.objectId, members: self.groupMembers, avatar: avatar)
        
        Group.saveGroup(group: group.groupDictionary)
        
        self.navigationController?.popViewController(animated: true)
    }



}
