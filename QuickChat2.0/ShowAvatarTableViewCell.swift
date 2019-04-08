//
//  ShowAvatarTableViewCell.swift
//  QuickChat2.0
//
//  Created by David Kababyan on 23/10/2016.
//  Copyright © 2016 David Kababyan. All rights reserved.
//

import UIKit
import MobileCoreServices

class ShowAvatarTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var showAvatarSwitch: UISwitch!
    
    let userDefaults = UserDefaults.standard
    var avatarSwitchStatus = true
    var firstLoad: Bool?

    override func awakeFromNib() {
        super.awakeFromNib()

        loadUserDefaults()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func avatarSwitchStatusChaged(_ sender: UISwitch) {
        
        if sender.isOn {
            avatarSwitchStatus = true
        } else {
            avatarSwitchStatus = false
        }
        
        saveUserDefaults()
    }
    
    
    //MARK: UserDefaults
    
    func saveUserDefaults() {
        
        userDefaults.set(avatarSwitchStatus, forKey: kAVATARSTATE)
        userDefaults.synchronize()
    }
    
    func loadUserDefaults() {
        
        firstLoad = userDefaults.bool(forKey: kFIRSTRUN)
        
        if !firstLoad! {
            userDefaults.set(true, forKey: kFIRSTRUN)
            userDefaults.set(avatarSwitchStatus, forKey: kAVATARSTATE)
            userDefaults.synchronize()
            
        }
        
        avatarSwitchStatus = userDefaults.bool(forKey: kAVATARSTATE)
        showAvatarSwitch.isOn = avatarSwitchStatus
    }
    


}
