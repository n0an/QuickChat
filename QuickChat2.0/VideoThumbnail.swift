//
//  VideoThumbnail.swift
//  QuickChat2.0
//
//  Created by David Kababyan on 21/10/2016.
//  Copyright © 2016 David Kababyan. All rights reserved.
//

import Foundation


func squareImage(image: UIImage, size: CGFloat) -> UIImage {
    
    var cropped: UIImage!
    
    if image.size.height > image.size.width {
        
        let ypos = (image.size.height - image.size.width) / 2
        cropped = cropImage(image: image, x: 0, y: ypos, width: image.size.width, height: image.size.height)
        
    } else {
        
        let xpos = (image.size.width - image.size.height) / 2
        
        cropped = cropImage(image: image, x: xpos, y: 0, width: image.size.width, height: image.size.height)
        
    }
    
    let resized = resizeImage(image: cropped, width: size, height: size, scale: 1)
    
    return resized
    
}


func cropImage(image: UIImage, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) -> UIImage {
    
    
    let rect = CGRect(x: x, y: x, width: width, height: height)
    
    let imageRef = image.cgImage!.cropping(to: rect)
    
    let cropped = UIImage(cgImage: imageRef!)
    
    return cropped
}


func resizeImage(image: UIImage, width: CGFloat, height: CGFloat, scale: CGFloat) -> UIImage {
    
    let size = CGSize(width: width, height: height)
    
    let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    
    UIGraphicsBeginImageContextWithOptions(size, false, scale)
    
    image.draw(in: rect)
    
    let resized = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return resized!
}
