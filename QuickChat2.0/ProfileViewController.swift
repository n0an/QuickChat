//
//  ProfileViewController.swift
//  QuickChat2.0
//
//  Created by David Kababyan on 12/11/2016.
//  Copyright © 2016 David Kababyan. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var user: FUser!
    var avatarImage: UIImage?
    
    
    @IBOutlet weak var changeAvatarButtonOutlet: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: IBActions

    @IBAction func cancelButtonPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }

    
    @IBAction func changeAvatarButtonPressed(_ sender: Any) {
        
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
    
    
    //MARK: Update UI
    

    func updateUI() {
        
        if user.objectId != FUser.currentId() {
            
            changeAvatarButtonOutlet.isHidden = true
        }
        
        
        let placeHolderImage = UIImage(named: "avatarPlaceholder")
        
        self.imageView.image = maskRoundedImage(image: placeHolderImage!, radius: Float(placeHolderImage!.size.width / 2))
        
        nameLabel.text = user.firstname
        
        if user.avatar != "" {
            
            imageFromData(pictureData: user.avatar, withBlock: {
                image in
                
                self.imageView.image = maskRoundedImage(image: image!, radius: Float(image!.size.width / 2))
                
            })

        }
        
    }
    
    
    //MARK: UIIMagepickercontroller delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        self.avatarImage = (info[UIImagePickerControllerEditedImage] as! UIImage)
        updateAvatarImage()
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    func updateAvatarImage() {
        
        if self.avatarImage != nil {
            
            let image = UIImageJPEGRepresentation(avatarImage!, 0.5)
            let avatar = image!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            
            let newDate = dateFormatter().string(from: Date())

            updateUser(withValues: [kAVATAR: avatar, kUPDATEDAT : newDate], withBlock: { (success) in
                
                if success {
                    self.user = FUser.currentUser()
                    self.updateUI()
                }
            })
        }

    }


}
