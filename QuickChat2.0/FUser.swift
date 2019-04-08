//
//  FUser.swift
//  QuickChat2.0
//
//  Created by David Kababyan on 16/12/2016.
//  Copyright © 2016 David Kababyan. All rights reserved.
//

import Foundation
import FirebaseAuth
import Firebase

class FUser {
    
    let objectId: String
    var pushId: String?
    
    let createdAt: Date
    var updatedAt: Date
    
    let email: String
    var firstname: String
    var lastname: String
    var fullname: String
    var avatar: String
    
    var friends: [String]
    
    let loginMethod: String
    
    //MARK: Initializers
    
    init(_objectId: String, _pushId: String?, _createdAt: Date, _updatedAt: Date, _email: String, _firstname: String, _lastname: String, _avatar: String = "", _loginMethod: String, _friends: [String]) {
        
        objectId = _objectId
        pushId = _pushId
        
        createdAt = _createdAt
        updatedAt = _updatedAt
        
        email = _email
        firstname = _firstname
        lastname = _lastname
        fullname = _firstname + " " + _lastname
        avatar = _avatar
        friends = _friends
        
        loginMethod = _loginMethod
        
    }
    
    init(_dictionary: NSDictionary) {
        
        objectId = _dictionary[kOBJECTID] as! String
        pushId = _dictionary[kPUSHID] as? String
        
        createdAt = dateFormatter().date(from: _dictionary[kCREATEDAT] as! String)!
        updatedAt = dateFormatter().date(from:_dictionary[kUPDATEDAT] as! String)!
        
        email = _dictionary[kEMAIL] as! String
        firstname = _dictionary[kFIRSTNAME] as! String
        lastname = _dictionary[kLASTNAME] as! String
        fullname = firstname + " " + lastname
        avatar = _dictionary[kAVATAR] as! String
        
        
        if let friend = _dictionary[kFRIEND] {
            
            friends = friend as! [String]

        } else {
            
            friends = []
        }
        
        
        loginMethod = _dictionary[kLOGINMETHOD] as! String
        
    }
    
    
    //MARK: Returning current user funcs

    class func currentId() -> String {
        
        return FIRAuth.auth()!.currentUser!.uid

    }
    
    class func currentUser () -> FUser? {
        
        if FIRAuth.auth()!.currentUser != nil {
            
            let dictionary = UserDefaults.standard.object(forKey: kCURRENTUSER)
            
            return FUser.init(_dictionary: dictionary as! NSDictionary)
        }
        
        return nil

    }


    
    //MARK: Login function
    
    class func loginUserWith(email: String, password: String, withBlock: @escaping (_ success: Bool) -> Void ) {
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (firUser, error) in
            
            if error != nil {
                
                print("Error loging in \(error!.localizedDescription)")
                withBlock(false)
                return
                
            } else {
                
                //get user from firebase
                fetchUser(userId: firUser!.uid, withBlock: { (success) in
                    
                    withBlock(success)
                })
            }
            
            
        })
        
        
    }
    
    //MARK: Register functions
    
    class func registerUserWith(email: String, password: String, firstName: String, lastName: String, avatar: String = "", withBlock: @escaping (_ success: Bool) -> Void) {
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (firuser, error) in
            
            if error != nil {
                
                print("Error Registering \(error!.localizedDescription)")
                withBlock(false)
                return
            }
            
            let fUser = FUser(_objectId: firuser!.uid, _pushId: "", _createdAt: Date(), _updatedAt: Date(), _email: firuser!.email!, _firstname: firstName, _lastname: lastName, _avatar: avatar, _loginMethod: kEMAIL, _friends: [])
            
            saveUserLocally(fUser: fUser)
            saveUserInBsckground(fUser: fUser)
            withBlock(true)

        })
        
    }
    
    
    //MARK: LogOut func

    class func logOutCurrentUser() {
        
        userDefaults.removeObject(forKey: "OneSignalId")
        removeOneSignalId()

        userDefaults.removeObject(forKey: kCURRENTUSER)
        userDefaults.synchronize()
        
        try! FIRAuth.auth()!.signOut()
        
    }
    
} //end of class funcs




//MARK: Save user funcs
func saveUserInBsckground(fUser: FUser, completion: @escaping (_ error: Error?) -> Void) {
    
    let ref = firebase.child(kUSER).child(fUser.objectId)
    
    ref.setValue(userDictionaryFrom(user: fUser)) { (error, ref) -> Void in
        
        completion(error)
        
    }
    
}

func saveUserInBsckground(fUser: FUser) {
    
    let ref = firebase.child(kUSER).child(fUser.objectId)
    
    ref.setValue(userDictionaryFrom(user: fUser))
    
}


func saveUserLocally(fUser: FUser) {
    
    UserDefaults.standard.set(userDictionaryFrom(user: fUser), forKey: kCURRENTUSER)
    UserDefaults.standard.synchronize()
    
}


//MARK: Fetch User funcs


func fetchUser(userId: String, withBlock: @escaping (_ success: Bool) -> Void) {
    
    firebase.child(kUSER).queryOrdered(byChild: kOBJECTID).queryEqual(toValue: userId).observe(.value, with: {
        snapshot in
        
        if snapshot.exists() {
            
            let user = ((snapshot.value as! NSDictionary).allValues as NSArray).firstObject! as! NSDictionary
            
            
            userDefaults.setValue(user, forKeyPath: kCURRENTUSER)
            userDefaults.synchronize()
            
            withBlock(true)
            
        } else {
            
            withBlock(false)
        }
        
    })
    
}


//MARK: Helper funcs

func userDictionaryFrom(user: FUser) -> NSDictionary {
    
    let createdAt = dateFormatter().string(from: user.createdAt)
    let updatedAt = dateFormatter().string(from: user.updatedAt)
    
    return NSDictionary(objects: [user.objectId,  createdAt, updatedAt, user.email, user.loginMethod, user.pushId!, user.firstname, user.lastname, user.fullname, user.avatar, user.friends], forKeys: [kOBJECTID as NSCopying, kCREATEDAT as NSCopying, kUPDATEDAT as NSCopying, kEMAIL as NSCopying, kLOGINMETHOD as NSCopying, kPUSHID as NSCopying, kFIRSTNAME as NSCopying, kLASTNAME as NSCopying, kFULLNAME as NSCopying, kAVATAR as NSCopying, kFRIEND as NSCopying])
    
}

func cleanupFirebaseObservers() {
    
    firebase.child(kUSER).removeAllObservers()
    firebase.child(kRECENT).removeAllObservers()
    firebase.child(kGROUP).removeAllObservers()
}


//MARK: Update current user funcs

func updateUser(withValues : [String : Any], withBlock: @escaping (_ success: Bool) -> Void) {
    
    
    let currentUser = FUser.currentUser()!
    
    let userObject = userDictionaryFrom(user: currentUser).mutableCopy() as! NSMutableDictionary
    
    userObject.setValuesForKeys(withValues)
    
    let ref = firebase.child(kUSER).child(FUser.currentId())
    
    ref.updateChildValues(withValues, withCompletionBlock: {
        error, ref in
        
        if error != nil {
            print("couldnt update user \(error?.localizedDescription)")
            withBlock(false)
            return
        }
        
        //update current user
        userDefaults.setValue(userObject, forKeyPath: kCURRENTUSER)
        userDefaults.synchronize()
        
        withBlock(true)
        
    })
}
    



//MARK: OneSignal

func updateOneSignalId() {
    
    if FUser.currentUser() != nil {
        
        if let pushId = UserDefaults.standard.string(forKey: "OneSignalId") {
            
            setOneSignalId(pushId: pushId)
            
        } else {
            
            removeOneSignalId()
        }
    }
}


func setOneSignalId(pushId: String) {
    
    updateCurrentUserOneSignalId(newId: pushId)
}


func removeOneSignalId() {
    
    updateCurrentUserOneSignalId(newId: "")
}

//MARK: Updating Current user funcs

func updateCurrentUserOneSignalId(newId: String) {
    
    let user = FUser.currentUser()
    user!.pushId = newId
    user!.updatedAt = Date()
    
    saveUserLocally(fUser: user!)
    saveUserInBsckground(fUser: user!)
}

func updateCurrentUserAvatar(newAvatar: String) {
    
    let user = FUser.currentUser()
    user!.avatar = newAvatar
    user!.updatedAt = Date()
    
    saveUserLocally(fUser: user!)
    saveUserInBsckground(fUser: user!)
}


