//
//  PushNotifications.swift
//  QuickChat2.0
//
//  Created by David Kababyan on 06/11/2016.
//  Copyright © 2016 David Kababyan. All rights reserved.
//

import Foundation
import OneSignal


let ref = firebase.child(kRECENT)
var shouldSendPush = false


func sendPushNotification1(chatRoomID: String, message: String) {
    
    ref.queryOrdered(byChild: kCHATROOMID).queryEqual(toValue: chatRoomID).observeSingleEvent(of: .value, with: {
        snapshot in
        
        if snapshot.exists() {
            
            let recents = (snapshot.value as! NSDictionary).allValues
            
            if let recent = recents.first as? NSDictionary {
                
                sendPushNotification2(members: (recent[kMEMBERS] as? [String])!, message: message)
            }
        }
        
    })
    
}



func sendPushNotification2(members: [String], message: String) {
    
    
    let newMembers = removeCurrentUserFromMembersArray(members: members)
    
    getMembersToPush(members: newMembers, result: {
        usersPushIDs in

        
        let currentUser = FUser.currentUser()
        
        OneSignal.postNotification(["contents": ["en": "\(currentUser!.firstname) \n \(message)"], "ios_badgeType" : "Increase", "ios_badgeCount" : "1", "include_player_ids": usersPushIDs])
        
    })
    
    
}


func numberOfUnreadMessagesOfUser(userId: String, result: @escaping (_ counter: Int) ->Void) {
    
    
    var counter = 0
    var resultCounter = 0
    
    ref.queryOrdered(byChild: kUSERID).queryEqual(toValue: userId).observe(.value, with: {
        snapshot in
        
        if snapshot.exists() {
            
            
            let recents = (snapshot.value as! NSDictionary).allValues
            
            for recent in recents {
                
                let currentRecent = recent as! NSDictionary
                
                let tempCount = (currentRecent[kCOUNTER] as? Int)!
                
                resultCounter += 1
                counter += tempCount
                
                
                if shouldSendPush {
                    
                    if resultCounter == recents.count {
                        
                        result(counter)
                    }
                }
                
            }
        }
        
        
    })
    
}



func removeCurrentUserFromMembersArray(members: [String]) -> [String] {
    
    var updatedMembers: [String] = []
    
    for member in members {
        
        if member != FUser.currentUser()!.objectId {
            
            updatedMembers.append(member)
        }
    }
    
    return updatedMembers
}


func getMembersToPush(members: [String], result: @escaping (_ usersArray: [String]) -> Void) {
    
    var fUserMemebrIDs: [String] = []
    var count = 0
    
    for memberId in members {
        
        firebase.child(kUSER).queryOrdered(byChild: kOBJECTID).queryEqual(toValue: memberId).observeSingleEvent(of: .value, with: {
            snapshot in
            
            if snapshot.exists() {
                
                let userDictionary = ((snapshot.value as! NSDictionary).allValues as Array).first
                
                let fUser = FUser.init(_dictionary: userDictionary as! NSDictionary)
                
                fUserMemebrIDs.append(fUser.pushId!)
                count += 1

                if members.count == count {
    
                    result(fUserMemebrIDs)
                }

            }
            
        })

    }
    
    
}






