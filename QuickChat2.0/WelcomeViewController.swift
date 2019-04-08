//
//  WelcomeViewController.swift
//  QuickChat2.0
//
//  Created by David Kababyan on 08/10/2016.
//  Copyright © 2016 David Kababyan. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import FirebaseAuth

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButtonOutlet: UIButton!
    @IBOutlet weak var registerButtonOutlet: UIButton!
    
    var firstLoad: Bool?

    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.isNavigationBarHidden = true
        
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in

            if let user = user {

                if userDefaults.object(forKey: kCURRENTUSER) != nil {

                    DispatchQueue.main.async {
                        self.goToApp()

                    }
                }
                
            } else {
                print("User is signed out.")
            }
        }


    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUserDefaults()
        
        loginButtonOutlet.layer.cornerRadius = 8
        loginButtonOutlet.layer.borderWidth = 1
        loginButtonOutlet.layer.borderColor = UIColor.white.cgColor
        
        registerButtonOutlet.layer.cornerRadius = 8
        registerButtonOutlet.layer.borderWidth = 1
        registerButtonOutlet.layer.borderColor = UIColor.white.cgColor

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func loginButtonPressed(_ sender: AnyObject) {
        
        if emailTextField.text != "" && passwordTextField.text != "" {
        
            ProgressHUD.show("Loging in...", interaction: false)

            FUser.loginUserWith(email: emailTextField.text!, password: passwordTextField.text!, withBlock: { (success) in
                
                ProgressHUD.dismiss()

                if success {
                    
                    self.emailTextField.text = nil
                    self.passwordTextField.text = nil
                    self.view.endEditing(false)
                    
                    //go to app
                    self.goToApp()
                }
                
            })
            
        }

    }
    
    
    @IBAction func facebookLoginButtonPressed(_ sender: Any) {
        
        let fbLoginManager = FBSDKLoginManager()
        
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email"], from: self, handler: {
            result, error in
            
            if error != nil {
                print("error loging in with facebook \(error?.localizedDescription)")
                return
            }
            
            
            if result?.token != nil {
                
                ProgressHUD.show("Loging in...", interaction: false)
                
                let credentials = FIRFacebookAuthProvider.credential(withAccessToken: result!.token.tokenString)
                
                FIRAuth.auth()?.signIn(with: credentials, completion: { (firuser, error) in
                    
                    if error != nil {
                        
                        print("Error loging in with facebook \(error?.localizedDescription)")
                        return
                    }
                    
                    self.isUserRegistered(userId: firuser!.uid, withBlock: { (isRegistered) in
                        
                        if !isRegistered {
                           
                            //do only when user is not registered yet
                            self.createFirebaseUserFromFacebook(withBlock: { (result, avatarImage) in
                                
                                let fUser = FUser(_objectId: firuser!.uid, _pushId: "", _createdAt: Date(), _updatedAt: Date(), _email: firuser!.email!, _firstname: result["first_name"] as! String, _lastname: result["last_name"] as! String, _avatar: avatarImage, _loginMethod: kFACEBOOK, _friends: [])
                                
                                saveUserLocally(fUser: fUser)
                                saveUserInBsckground(fUser: fUser, completion: { (error) in
                                    
                                    if error == nil {
                                        
                                        ProgressHUD.dismiss()
                                        self.goToApp()
                                    }

                                })
                                
                            })
                            
                        } else {
                            
                            ProgressHUD.dismiss()
                            //login user and dont reg him
                            fetchUser(userId: firuser!.uid, withBlock: { (success) in
                                
                                if success {
                                    
                                    self.goToApp()
                                }

                            })
                            
                        }
                        
                    })
                    
                })
            }
            
        })
    }
    
    func createFirebaseUserFromFacebook(withBlock: @escaping (_ result: NSDictionary, _ avatarImage: String) -> Void) {
        
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "email, first_name, last_name, name"]).start { (connection, result, error) in
            
            
            if error != nil {
                
                print("Error facebook request \(error?.localizedDescription)")
                return
            }
            
            
            if let facebookId = (result as! NSDictionary)["id"] as? String {
                
                let avatarUrl = "http://graph.facebook.com/\(facebookId)/picture?type=normal"
                
                getImageFromURL(url: avatarUrl, withBlock: { (image) in
                    
                    //convert avatar image to string
                    let image = UIImageJPEGRepresentation(image!, 0.5)
                    let avatarString = image!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))

                    
                    withBlock(result as! NSDictionary, avatarString)
                })
                
            } else {
                
                print("Facebook request erro, no facebook id")
                
                //return result only
                withBlock(result as! NSDictionary, "")

            }
            
        }
        
    }
    
    func isUserRegistered(userId: String, withBlock: @escaping (_ result: Bool) -> Void) {
        
        firebase.child(kUSER).queryOrdered(byChild: kOBJECTID).queryEqual(toValue: userId).observeSingleEvent(of: .value, with: {
            snapshot in
            
            if snapshot.exists() {
                
                withBlock(true)
                
            } else {

                withBlock(false)
            }
            
        })

    }
    
    func goToApp() {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UserDidLoginNotification"), object: nil, userInfo: ["userId" : FUser.currentId()])
        
        
        //go to app
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RecentVC") as! UITabBarController
        
        vc.selectedIndex = 0
        
        self.present(vc, animated: true, completion: nil)

    }
    
    //firstRun check
    func setUserDefaults() {
        
        firstLoad = userDefaults.bool(forKey: kFIRSTRUN)
        
        if !firstLoad! {
            
            userDefaults.set(true, forKey: kFIRSTRUN)
            userDefaults.set(true, forKey: kAVATARSTATE)
            
            userDefaults.set(1.0, forKey: kRED)
            userDefaults.set(1.0, forKey: kGREEN)
            userDefaults.set(1.0, forKey: kBLUE)
            
            userDefaults.synchronize()
        }
        
    }

    
}
