//
//  Utilities.swift
//  QuickChat2.0
//
//  Created by David Kababyan on 09/10/2016.
//  Copyright © 2016 David Kababyan. All rights reserved.
//

import Foundation
import Firebase

private let dateFormat = "yyyyMMddHHmmss"

func dateFormatter() -> DateFormatter {
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = dateFormat
    
    return dateFormatter
}

func userDataFromCallerId(callerId: String, result: @escaping (_ callerName: String?, _ avatar: UIImage?) -> Void) {
    
    var avatarImage = UIImage(named: "avatarPlaceholder")

    firebase.child(kUSER).queryOrdered(byChild: kOBJECTID).queryEqual(toValue: callerId).observeSingleEvent(of: .value, with: {
        snapshot in
        

        if snapshot.exists() {
            
            let userDictionary = ((snapshot.value as! NSDictionary).allValues as Array).first
            
            let fUser = FUser.init(_dictionary: userDictionary as! NSDictionary)
            
            
            if fUser.avatar != "" {
                imageFromData(pictureData: fUser.avatar, withBlock: { (image) in
                    
                    avatarImage = image!
                    result(fUser.fullname, avatarImage)

                })

            } else {
                result(fUser.fullname, avatarImage)
            }
            
            
        } else {
            
            result("Unknown Caller", avatarImage)

        }
        
    })

}

func maskRoundedImage(image: UIImage, radius: Float) -> UIImage {
    
    let imageView: UIImageView = UIImageView(image: image)
    var layer: CALayer = CALayer()
    layer = imageView.layer
    
    layer.masksToBounds = true
    layer.cornerRadius = CGFloat(radius)
    
    UIGraphicsBeginImageContext(imageView.bounds.size)
    layer.render(in: UIGraphicsGetCurrentContext()!)
    let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return roundedImage!
}

func imageFromData(pictureData: String, withBlock: (_ image: UIImage?) -> Void) {
    
    var image: UIImage?
    
    let decodedData = NSData(base64Encoded: pictureData, options: NSData.Base64DecodingOptions(rawValue: 0))
    
    
    image = UIImage(data: decodedData! as Data)
    
    withBlock(image)
    
}

