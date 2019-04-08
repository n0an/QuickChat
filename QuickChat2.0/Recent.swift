//
//  Recent.swift
//  QuickChat2.0
//
//  Created by David Kababyan on 09/10/2016.
//  Copyright © 2016 David Kababyan. All rights reserved.
//

import Foundation


func startChat(user1: FUser, user2: FUser) -> String {
    
    let userId1 = user1.objectId as String
    let userId2 = user2.objectId as String
    
    var chatRoomId: String = ""
    
    let value = userId1.compare(userId2).rawValue
    
    if value < 0 {
        chatRoomId = userId1 + userId2
        
    } else {
        chatRoomId = userId2 + userId1
    }
    
    let members = [userId1, userId2]
    
    createRecent(userId: userId1, chatRoomId: chatRoomId, members: members, withUserUserId: userId2, withUserUsername: user2.firstname, type: kPRIVATE)
    createRecent(userId: userId2, chatRoomId: chatRoomId, members: members, withUserUserId: userId1, withUserUsername: user1.firstname, type: kPRIVATE)
    
    
    return chatRoomId
}


func createRecent(userId: String, chatRoomId: String, members: [String], withUserUserId: String, withUserUsername: String, type: String) {

    firebase.child(kRECENT).queryOrdered(byChild: kCHATROOMID).queryEqual(toValue: chatRoomId).observeSingleEvent(of: .value, with: {
        snapshot in
        
        var create = true
        
        if snapshot.exists() {

            for recent in ((snapshot.value as! NSDictionary).allValues as Array) {

                let currentRecent = recent as! NSDictionary
                
                if currentRecent[kUSERID] as! String == userId {
                    
                    create = false
                    
                }
                
            }
            
        }
        
        if create {
            
            creatRecentItem(userId: userId, chatRoomId: chatRoomId, members: members, withUserUserId: withUserUserId, withUserUsername: withUserUsername, type: type)
        }
        
    })
    
}

func creatRecentItem(userId: String, chatRoomId: String, members: [String], withUserUserId: String, withUserUsername: String, type: String) {
    
    let refernce = firebase.child(kRECENT).childByAutoId()
    
    let recentId = refernce.key
    let date = dateFormatter().string(from: Date())
    
    
    let recent = [kRECENTID: recentId, kUSERID: userId, kCHATROOMID: chatRoomId, kMEMBERS: members, kWITHUSERUSERNAME: withUserUsername, kWITHUSERUSERID: withUserUserId, kLASTMESSAGE: "", kCOUNTER: 0, kDATE: date, kTYPE: type] as [String : Any]
    

    refernce.setValue(recent) { (error, ref) in
        
        print("created")

        if error != nil {
            
            ProgressHUD.showError("Couldnt create recent: \(error!.localizedDescription)")
        }
        
    }
}

func restartRecentChat(recent: NSDictionary) {
    
    if (recent[kTYPE] as? String)! == kPRIVATE {
        
        for userId in recent[kMEMBERS] as! [String] {
            
            if userId != FUser.currentUser()!.objectId {
                
                createRecent(userId: userId, chatRoomId: (recent[kCHATROOMID] as? String)!, members: recent[kMEMBERS] as! [String], withUserUserId: FUser.currentUser()!.objectId, withUserUsername: FUser.currentUser()!.firstname, type: kPRIVATE)
            }
            
        }
        
    }
    
    if (recent[kTYPE] as? String)! == kGROUP {
        
        createGroupRecent(chatRoomID: (recent[kCHATROOMID] as? String)!, members: (recent[kMEMBERS] as? [String])!, groupName: (recent[kWITHUSERUSERNAME] as? String)!, ownerID: (recent[kUSERID] as? String)!, type: kGROUP)
        
    }
    
}


func updateRecents(chatRoomId: String, lastMessage: String) {
    
    firebase.child(kRECENT).queryOrdered(byChild: kCHATROOMID).queryEqual(toValue: chatRoomId).observeSingleEvent(of: .value, with: {
        snapshot in
        
        if snapshot.exists() {
            
            for recent in ((snapshot.value as! NSDictionary).allValues as Array) {
            
                updateRecentItem(recent: recent as! NSDictionary, lastMessage: lastMessage)
            }
        }
        
    })
    
}

func updateRecentItem(recent: NSDictionary, lastMessage: String) {
    
    let date = dateFormatter().string(from: Date())
    
    var counter = recent[kCOUNTER] as! Int
    
    if recent[kUSERID] as? String != FUser.currentUser()!.objectId {
        
        counter += 1
    }
    
    let values = [kLASTMESSAGE: lastMessage, kCOUNTER: counter, kDATE: date] as [String : Any]
    
    
    firebase.child(kRECENT).child((recent[kRECENTID] as? String)!).updateChildValues(values as [NSObject : AnyObject]) {
        (error, ref) -> Void in
        
        if error != nil {
            
            ProgressHUD.showError("Couldnt update recent: \(error!.localizedDescription)")
        }
        
    }
    
}

func clearRecentCounter(chatRoomID: String) {
    
    firebase.child(kRECENT).queryOrdered(byChild: kCHATROOMID).queryEqual(toValue: chatRoomID).observeSingleEvent(of: .value, with: {
        snapshot in
        
        if snapshot.exists() {
            
            for recent in ((snapshot.value as! NSDictionary).allValues as Array) {
                
                let currentRecent = recent as! NSDictionary
                
                if currentRecent[kUSERID] as? String == FUser.currentUser()!.objectId {
                    
                    clearRecentCounterItem(recent: currentRecent)
                }
                
                
            }
        }
    })
}

func clearRecentCounterItem(recent: NSDictionary) {
    
    firebase.child(kRECENT).child((recent[kRECENTID] as? String)!).updateChildValues([kCOUNTER : 0]) { (error, ref) -> Void in
        
        if error != nil {
            
            ProgressHUD.showError("Couldnt celar recent counter \(error!.localizedDescription)")
        }
    }
    
}

func deleteRecentItem(recentID: String) {
    
    firebase.child(kRECENT).child(recentID).removeValue { (error, ref) in
        
        if error != nil {
            
            ProgressHUD.showError("Couldnt delete recent item: \(error!.localizedDescription)")
        }
    }
    
}

func deleteMultipleRecentItems(chatRoomID: String) {
    
    firebase.child(kRECENT).queryOrdered(byChild: kCHATROOMID).queryEqual(toValue: chatRoomID).observeSingleEvent(of: .value, with: {
        snapshot in
        
        if snapshot.exists() {
            
            for recent in ((snapshot.value as! NSDictionary).allValues as Array) {
                
                let currentRecent = recent as! NSDictionary
                
                deleteRecentItem(recentID: (currentRecent[kRECENTID] as? String)!)
                
            }
            
        }
    })
    
}

func deleteRecentWithNotification(recent: NSDictionary) {
    
    let index = (recent[kMEMBERS] as? [String])!.index(of: FUser.currentUser()!.objectId)
    
    var newMembers = (recent[kMEMBERS] as? [String])!
    newMembers.remove(at: index!)
    
    if (recent[kMEMBERS] as? [String])!.count > 2 {
        
        firebase.child(kGROUP).queryOrdered(byChild: kGROUPID).queryEqual(toValue: recent[kCHATROOMID] as? String).observeSingleEvent(of: .value, with: {
            snapshot in
            
            if snapshot.exists() {
                
                for group in ((snapshot.value as! NSDictionary).allValues as Array) {
                    
                    //1. delete recent
                    deleteRecentItem(recentID: (recent[kRECENTID] as? String)!)
                    
                    //2. remove current user from group members
                    removeCurrentUserFromGroup(group: group as! NSDictionary)
                    
                    //3. remove current user from recents
                    updateMembersInRecent(members: newMembers, group: group as! NSDictionary)
                }
                
            }
            
        })
        
        
    } else {
        
        //delete the group
        Group.deleteGroup(groupId: (recent[kCHATROOMID] as? String)!)
    }
    
    
}


func removeCurrentUserFromGroup(group: NSDictionary) {
    
    var newMembers = (group[kMEMBERS] as? [String])!
    
    let index = newMembers.index(of: FUser.currentUser()!.objectId)
    newMembers.remove(at: index!)
    
    var updatedValues: NSDictionary!
    
    if (group[kOWNERID] as? String)! == FUser.currentUser()!.objectId {
        
        updatedValues = [kOWNERID : "", kMEMBERS : newMembers]
    } else {
        
        updatedValues = [kMEMBERS : newMembers]
    }
    
    firebase.child(kGROUP).child((group[kGROUPID] as? String)!).updateChildValues(updatedValues as! [AnyHashable : Any]) { (error, ref) in
        
        
        if error != nil {
            
            ProgressHUD.showError("Couldnt update group Members: \(error!.localizedDescription)")
        }
        
    }
}

func updateMembersInRecent(members: [String], group: NSDictionary) {
    
    firebase.child(kRECENT).queryOrdered(byChild: kCHATROOMID).queryEqual(toValue: (group[kGROUPID] as? String)!).observeSingleEvent(of: .value, with: {
        snapshot in
        
        
        if snapshot.exists() {
            
            for recent in ((snapshot.value as! NSDictionary).allValues as Array) {
                
                updateRecentGroupMembers(members: members, recent: recent as! NSDictionary)
            }
        }
    })
    
    
}

func updateRecentGroupMembers(members: [String], recent: NSDictionary) {
    
    let values = [kMEMBERS : members]
    
    firebase.child(kRECENT).child((recent[kRECENTID] as? String)!).updateChildValues(values) { (error, ref) in
        
        if error != nil {
            
            ProgressHUD.showError("Couldnt update recent members: \(error!.localizedDescription)")
        }
        
    }
    
}



func updateChatStatus(chat: NSDictionary, chatRoomId: String) {
    
    let values = [kSTATUS : kREAD]
    
    firebase.child(kMESSAGE).child(chatRoomId).child((chat[kMESSAGEID] as? String)!).updateChildValues(values)
    
}

//group Chats

func startGroupChat(group: NSDictionary) {
    
    createGroupRecent(chatRoomID: (group[kGROUPID] as? String)!, members: (group[kMEMBERS] as? [String])!, groupName: (group[kNAME] as? String)!, ownerID: FUser.currentUser()!.objectId, type: kGROUP)
    
}

func createGroupRecent(chatRoomID: String, members: [String], groupName: String, ownerID: String, type: String) {
    
    firebase.child(kRECENT).queryOrdered(byChild: kCHATROOMID).queryEqual(toValue: chatRoomID).observeSingleEvent(of: .value, with: {
        snapshot in
        
        var memberIDs = members
        
        if snapshot.exists() {
            
            for recent in ((snapshot.value as! NSDictionary).allValues as Array) {
                
                let currentRecent = recent as! NSDictionary
                
                if members.contains((currentRecent[kUSERID] as? String)!) {
                    
                    let index = memberIDs.index(of: (currentRecent[kUSERID] as? String)!)
                    
                    memberIDs.remove(at:  index!)
                    
                }
                
            }

        }
        
        for userID in memberIDs {
            creatRecentItem(userId: userID, chatRoomId: chatRoomID, members: members, withUserUserId: "", withUserUsername: groupName, type: type)
        }
        
        
    })
    
}


func deleteChatroom(chatRoomID: String) {
    
    firebase.child(kMESSAGE).child(chatRoomID).removeValue { (error, ref) in
        
        if error != nil {
            
            ProgressHUD.showError("Couldnt delete chatroom: \(error!.localizedDescription)")
        }
    }
    
}

