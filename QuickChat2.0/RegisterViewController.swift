//
//  RegisterViewController.swift
//  QuickChat2.0
//
//  Created by David Kababyan on 08/10/2016.
//  Copyright © 2016 David Kababyan. All rights reserved.
//

import UIKit
import MobileCoreServices
import Firebase


class RegisterViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var firstnameTextField: UITextField!
    
    @IBOutlet weak var lastnameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registerButtonOutlet: UIButton!
    
    var avatarImage: UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.isNavigationBarHidden = false
        
        registerButtonOutlet.layer.cornerRadius = 8
        registerButtonOutlet.layer.borderWidth = 1
        registerButtonOutlet.layer.borderColor = UIColor.white.cgColor


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: IBActions

    @IBAction func registerButtonPressed(_ sender: AnyObject) {
        
        if emailTextField.text != "" && firstnameTextField.text != "" && lastnameTextField.text != "" && passwordTextField.text != "" {
        
            ProgressHUD.show("Registering...", interaction: false)

            //set default avatar
            var avatar = ""
            
            //set avatar if we have one
            if self.avatarImage != nil {
                
                let image = UIImageJPEGRepresentation(avatarImage!, 0.5)
                avatar = image!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            }

            
            FUser.registerUserWith(email: emailTextField.text!, password: passwordTextField.text!, firstName: firstnameTextField.text!, lastName: lastnameTextField.text!, avatar: avatar, withBlock: { (success) in
                
                ProgressHUD.dismiss()
                
                if success {

                    //post notification
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UserDidLoginNotification"), object: nil, userInfo: ["userId" : FUser.currentId()])

                    //go to app
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RecentVC") as! UITabBarController
                    
                    vc.selectedIndex = 0
                    
                    self.present(vc, animated: true, completion: nil)
                    
                }
                
            })
            
        } else {
            
            ProgressHUD.showError("All fields are required!")
        }
        
    }
    
    
    @IBAction func cameraButtonPressed(_ sender: AnyObject) {
        
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
        
        self.avatarImage = (info[UIImagePickerControllerEditedImage] as! UIImage)
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    


    
}
