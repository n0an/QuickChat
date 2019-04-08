//
//  VideoMessage.swift
//  QuickChat2.0
//
//  Created by David Kababyan on 21/10/2016.
//  Copyright © 2016 David Kababyan. All rights reserved.
//

import Foundation

class VideoMessage: JSQMediaItem {
    
    var image: UIImage?
    var videoImageView: UIImageView?
    var status: Int?
    var fileURL: NSURL?
    
    
    init(withFileURL: NSURL, maskOutgoing: Bool) {
        
        super.init(maskAsOutgoing: maskOutgoing)
        
        fileURL = withFileURL
        videoImageView = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func mediaView() -> UIView! {
        
        if let st = status {
            
            if st == 1 {
                
                    return nil
            }
            
            if st == 2 && (self.videoImageView == nil) {
                
                
                let size = self.mediaViewDisplaySize
                let outgoing = self.appliesMediaViewMaskAsOutgoing
                
                let icon = UIImage.jsq_defaultPlay().jsq_imageMasked(with: UIColor.white)
                
                let iconView = UIImageView(image: icon)
                
                iconView.frame = CGRect(x: 0, y: 0, width: size().width, height: size().height)
                
                iconView.contentMode = UIViewContentMode.center
                
                let imageView = UIImageView(image: self.image!)
                
                imageView.frame = CGRect(x: 0, y: 0, width: size().width, height: size().height)
                
                imageView.contentMode = UIViewContentMode.scaleAspectFill
                imageView.clipsToBounds = true
                imageView.addSubview(iconView)
                
                JSQMessagesMediaViewBubbleImageMasker.applyBubbleImageMask(toMediaView: imageView, isOutgoing: outgoing)
                
                self.videoImageView = imageView
            }
            
        }
        
        return self.videoImageView
    }
    
}
