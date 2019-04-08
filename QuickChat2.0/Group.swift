//
//  Group.swift
//  QuickChat2.0
//
//  Created by David Kababyan on 29/10/2016.
//  Copyright © 2016 David Kababyan. All rights reserved.
//

import Foundation

class Group {
    
    let groupDictionary: NSMutableDictionary
    
    init (name: String, ownerId: String, members: [String], avatar: String) {
        
        groupDictionary = NSMutableDictionary(objects: [name, ownerId, members, avatar], forKeys: [kNAME as NSCopying, kOWNERID as NSCopyig, kMEMBERS as NSCopying, kAVATAR as NSCopying])
    }
    
    
    class func saveGroup(group: NSMutableDictionary) {
        
        let reference = firebase.child(kGROUP).childByAutoId()
        let date = dateFormatter().string(from: Date())
        
        group[kGROUPID] = reference.key
        group[kDATE] = date
        
        reference.setValue(group) { (error, ref) in
            
            if error != nil {
                
                ProgressHUD.showError("Error saving group: \(error!.localizedDescription)")
            }
        }
        
    }
    
    
    class func deleteGroup(groupId: String) {
        
        firebase.child(kGROUP).child(groupId).removeValue { (error, ref) in
            
            if error != nil {
                
                ProgressHUD.showError("Couldnt delete group \(error!.localizedDescription)")
            } else {
                
                deleteMultipleRecentItems(chatRoomID: groupId)
                
                deleteChatroom(chatRoomID: groupId)
            }
        }
    }
    
}
