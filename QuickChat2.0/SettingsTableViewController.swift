//
//  SettingsTableViewController.swift
//  QuickChat2.0
//
//  Created by David Kababyan on 23/10/2016.
//  Copyright © 2016 David Kababyan. All rights reserved.
//

import UIKit
import MobileCoreServices
import FBSDKLoginKit
import FBSDKCoreKit

class SettingsTableViewController: UITableViewController {

    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }


    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {

        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if section == 0 { return 1 }
        if section == 1 { return 4 }
        if section == 2 { return 1 }
        
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 && indexPath.row == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "AvatarCell", for: indexPath) as! FriendTableViewCell
            
            cell.bindData(friend: FUser.currentUser()!)
            
            return cell
        }
        
        if indexPath.section == 1 && indexPath.row == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "privacyCell", for: indexPath)
            
            cell.textLabel?.text = "Privacy Policy"
            
            return cell
        }
        
        if indexPath.section == 1 && indexPath.row == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "termsCell", for: indexPath)
            
            cell.textLabel?.text = "Terms of Service"
            
            return cell
        }
        
        if indexPath.section == 1 && indexPath.row == 2 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "backgroundCell", for: indexPath)
            
            cell.textLabel?.text = "Backgrounds"
            
            return cell
        }
        if indexPath.section == 1 && indexPath.row == 3 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "showAvatarCell", for: indexPath) as! ShowAvatarTableViewCell
            
            return cell
        }
        if indexPath.section == 2 && indexPath.row == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "logoutCell", for: indexPath)
            
            return cell
        }
        

        return UITableViewCell()
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView()
        view.backgroundColor = tableView.backgroundColor
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return 50
        } else {
            return 20
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        if indexPath.section == 0 {
            return 70
        } else {
            return 44
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 && indexPath.row == 0 {
            
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
            
            vc.user = FUser.currentUser()!
            
            self.present(vc, animated: true, completion: nil)
        }
        
        if indexPath.section == 1 && indexPath.row == 0 {
            
            //show privacy
        }
        
        if indexPath.section == 1 && indexPath.row == 1 {
            
            //show Terms of service
        }
        
        if indexPath.section == 1 && indexPath.row == 2 {
            
            //show Backgrounds
            performSegue(withIdentifier: "settingsToBackgroundSeg", sender: self)
        }
        
        if indexPath.section == 2 && indexPath.row == 0 {
            
            showLogoutView()
        }

    }
    
    func showLogoutView() {
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let logOut = UIAlertAction(title: "Log Out", style: .destructive) { (alert: UIAlertAction!) in
            
            self.logOut()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert: UIAlertAction!) in
            
        }
        
        optionMenu.addAction(logOut)
        optionMenu.addAction(cancelAction)
        
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func logOut() {
        
        cleanupFirebaseObservers()

        FUser.logOutCurrentUser()
        
        //log out from facebook
        if FBSDKAccessToken.current() != nil {
            
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
        }
        
        
        
        let login = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WelcomeView")
        
        self.present(login, animated: true, completion: nil)
        
    }
    
    

}
