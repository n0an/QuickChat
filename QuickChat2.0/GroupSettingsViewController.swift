//
//  GroupSettingsViewController.swift
//  QuickChat2.0
//
//  Created by David Kababyan on 29/10/2016.
//  Copyright © 2016 David Kababyan. All rights reserved.
//

import UIKit

class GroupSettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, EditGroupDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    var groupNameTextField: UITextField!
    
    var group: NSDictionary? = nil
    var users: [FUser] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()


        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backArrow"), style: .plain, target: self, action: #selector(GroupSettingsViewController.backAction))

    }
    
    override func viewWillDisappear(_ animated: Bool) {

        firebase.child(kUSER).removeAllObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {

        getUsersFromFirebase(userIds: (group![kMEMBERS] as? [String])!)
    }
    
    func backAction() {
        
        firebase.child(kUSER).removeAllObservers()
        
        self.navigationController?.popViewController(animated: true)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: TableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            
            return 1
        } else {
            
            return users.count
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! GroupNameTableViewCell
            
            cell.bindData(group: group!, withMembers: false)
            
            return cell
        
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as! FriendTableViewCell
            
            cell.bindData(friend: users[indexPath.row])
            
            return cell
        }
        
    }
    
    //MARK: TableViewDelegate
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        
        if section != 0 {
            return "Members"
        } else {
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return 20.0
        } else {
            
            return 40.0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {

            startGroupChat(group: group!)
            
            let chatVC = ChatViewController()
            chatVC.chatRoomId = group![kGROUPID] as? String
            chatVC.members = (group![kMEMBERS] as? [String])!
            chatVC.titleName = (group![kNAME] as? String)!
            chatVC.isGroup = true
            
            chatVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(chatVC, animated: true)
            
        } else {
            
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
            
            vc.user = users[indexPath.row]
            
            self.present(vc, animated: true, completion: nil)
        }
        
    }

    
    
    
    //MARK: IBActions
    
    @IBAction func editBarButtonItemPressed(_ sender: AnyObject) {
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let renameAction = UIAlertAction(title: "Rename Group", style: .default) { (action: UIAlertAction!) in
            
            self.renameGroup()
        }
        
        let addMembers = UIAlertAction(title: "Add Members", style: .default) { (action: UIAlertAction!) in
            
            self.performSegue(withIdentifier: "groupSettingsToAddMemberSeg", sender: nil)
            
        }
        
        let changeAvatar = UIAlertAction(title: "Change Avatar", style: .default) { (action: UIAlertAction!) in
            
            
            self.showCameraOptions()
        }

        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action: UIAlertAction!) in
        }
        
        optionMenu.addAction(renameAction)
        optionMenu.addAction(addMembers)
        optionMenu.addAction(changeAvatar)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func renameGroup() {
        
        let alertController = UIAlertController(title: "Rename Group", message: "Enter a new name for this group", preferredStyle: .alert)
        
        alertController.addTextField { (nameTextField) in
            
            nameTextField.placeholder = "Name"
            self.groupNameTextField = nameTextField
        }
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        
        let saveAtion = UIAlertAction(title: "Save", style: .default) { (action) in
            
            if self.groupNameTextField.text != "" {
                
                self.updateFirebaseGroupName(newName: self.groupNameTextField.text!)
            }
            
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAtion)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func updateFirebaseGroupName(newName: String) {
        
        let newGroup = group!.mutableCopy() as! NSMutableDictionary
        newGroup.setValue(newName, forKey: kNAME)
        group = newGroup
        
        tableView.reloadData()
        
        
        let groupId = group![kGROUPID] as? String
        let values = [kNAME: newName]
        
        firebase.child(kGROUP).child(groupId!).updateChildValues(values)
        
        //update recents
        firebase.child(kRECENT).queryOrdered(byChild: kCHATROOMID).queryEqual(toValue: groupId!).observeSingleEvent(of: .value, with: {
            snapshot in
            
            if snapshot.exists() {
                
                
                for recent in (snapshot.value! as! NSDictionary).allValues {
                    
                    self.updateRecentGroupName(newName: newName, recent: recent as! NSDictionary)
                    
                }
            }
        })

    }
    
    func updateRecentGroupName(newName: String, recent: NSDictionary) {
        
        let values = [kWITHUSERUSERNAME : newName]
        
        firebase.child(kRECENT).child((recent[kRECENTID] as? String)!).updateChildValues(values) { (error, ref) in
            
            if error != nil {
                
                ProgressHUD.showError("Couldnt update recent group name: \(error!.localizedDescription)")
            }
        }
        
    }


    //MARK: Helper functions
    
    func getUsersFromFirebase(userIds: [String]) {
        
        users.removeAll()
        
        //go through each friend and download it from firebase
        for userId in userIds {
            
            firebase.child(kUSER).queryOrdered(byChild: kOBJECTID).queryEqual(toValue: userId).observe(.value, with: {
                snapshot in
                
                if snapshot.exists() {
                    
                    let userDictionary = ((snapshot.value as! NSDictionary).allValues as Array).first
                    
                    let fUser = FUser.init(_dictionary: userDictionary as! NSDictionary)
                    
                    self.users.append(fUser)
                    
                }
                
                self.tableView.reloadData()
            })

        
        }
        
        
    }
    
    //MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "groupSettingsToAddMemberSeg" {
            
            let vc = segue.destination as! EditGroupViewController
            vc.group = self.group
            vc.delegate = self
            
        }
    }
    
    //MARK: EditGroupDelegate function
    
    func finishedEditingGroup(updatedGroup: NSDictionary) {
        
        self.group = updatedGroup
        getUsersFromFirebase(userIds: (group![kMEMBERS] as? [String])!)
    }
    
    
    //MARK: Chage Avatar
    
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
        saveGroupAvatar(avatarImage: avatarImage)
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    func saveGroupAvatar(avatarImage: UIImage) {
        
        let image = UIImageJPEGRepresentation(avatarImage, 0.5)
        
        let avatar = image!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))

        let newGroup = self.group!.mutableCopy() as! NSMutableDictionary
        newGroup.setValue(avatar, forKey: kAVATAR)
        self.group = newGroup
        
        self.tableView.reloadData()
        
        
        let groupId = self.group![kGROUPID] as? String
        let values = [kAVATAR: avatar]
        
        firebase.child(kGROUP).child(groupId!).updateChildValues(values)

    }

    

    

    

}
