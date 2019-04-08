//
//  IncomingMessage.swift
//  QuickChat2.0
//
//  Created by David Kababyan on 15/10/2016.
//  Copyright © 2016 David Kababyan. All rights reserved.
//

import Foundation

public class IncomingMessage {
    
    var collectionView: JSQMessagesCollectionView
    
    init(collectionView_: JSQMessagesCollectionView) {
        collectionView = collectionView_
    }
    
    
    
    func createMessage(dictionary: NSDictionary, chatRoomID: String) -> JSQMessage? {
        
        var message: JSQMessage?
        
        let type = dictionary[kTYPE] as? String
        
        if type == kTEXT {
            
            message = createTextMessage(item: dictionary, chatRoomId: chatRoomID)
        }
        
        if type == kLOCATION {
            
            message = createLocationMessage(item: dictionary)
        }
        
        if type == kPICTURE {
            
            message = createPictureMessage(item: dictionary)
        }
        
        if type == kVIDEO {
            
            message = createVideoMessage(item: dictionary)
        }
        
        if type == kAUDIO {
            
            message = createAudioMessage(item: dictionary)
        }
        
        if let mes = message {
            return message
        }
        
        return nil
    }
    
    func createAudioMessage(item: NSDictionary) -> JSQMessage {
        
        let name = item[kSENDERNAME] as? String
        let userId = item[kSENDERID] as? String
        
        let date = dateFormatter().date(from: (item[kDATE] as? String)!)
        let audioURL = NSURL(fileURLWithPath: item[kAUDIO] as! String)
        
        let mediaItem = AudioMessage(withFileURL: audioURL, maskOutgoing: returnOutgoingStatusFromUser(senderId: userId!))
        
        downloadAudio(audioUrl: item[kAUDIO] as! String) { (fileName) in
            
            
            let url = NSURL(fileURLWithPath: fileInDocumentsDirectory(filename: fileName))
            
            mediaItem.status = kSUCCESS
            mediaItem.fileURL = url
            
            self.collectionView.reloadData()
        }
        
        return JSQMessage(senderId: userId!, senderDisplayName: name!, date: date, media: mediaItem)
        
    }
    
    
    func createVideoMessage(item: NSDictionary) -> JSQMessage {

        let name = item[kSENDERNAME] as? String
        let userId = item[kSENDERID] as? String
        
        let date = dateFormatter().date(from: (item[kDATE] as? String)!)
        let videoURL = NSURL(fileURLWithPath: item[kVIDEO] as! String)
        
        let mediaItem = VideoMessage(withFileURL: videoURL, maskOutgoing: returnOutgoingStatusFromUser(senderId: userId!))
        
        
        downloadVideo(videoUrl: item[kVIDEO] as! String) { (isReadyToPlay, fileName) in
            
            let url = NSURL(fileURLWithPath: fileInDocumentsDirectory(filename: fileName))
            
            
            mediaItem.status = kSUCCESS
            mediaItem.fileURL = url
            
            imageFromData(pictureData: (item[kPICTURE] as? String)!, withBlock: { (image) in
                
                //setting the image when downloaded
                mediaItem.image = image!
                self.collectionView.reloadData()

            })

            self.collectionView.reloadData()
            
        }
        
        return JSQMessage(senderId: userId!, senderDisplayName: name!, date: date, media: mediaItem)
        
    }

    
    func createTextMessage(item: NSDictionary, chatRoomId: String) -> JSQMessage {
        
        let name = item[kSENDERNAME] as? String
        let userId = item[kSENDERID] as? String
        
        let date = dateFormatter().date(from: (item[kDATE] as? String)!)
        
        
        let decryptedText = DecryptText(chatRoomID: chatRoomId, string: (item[kMESSAGE] as? String)!)
        
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, text: decryptedText)
        
    }
    
    func createPictureMessage(item: NSDictionary) -> JSQMessage {
        
        let name = item[kSENDERNAME] as? String
        let userId = item[kSENDERID] as? String
        
        let date = dateFormatter().date(from: (item[kDATE] as? String)!)
        
        let mediaItem = JSQPhotoMediaItem(image: nil)
        
        mediaItem?.appliesMediaViewMaskAsOutgoing = returnOutgoingStatusFromUser(senderId: userId!)
        
        imageFromData(pictureData: (item[kPICTURE] as? String)!) { (image) in
            
            mediaItem?.image = image
            self.collectionView.reloadData()

        }
        
        
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, media: mediaItem)
    }
    
    func createLocationMessage(item: NSDictionary) -> JSQMessage {
        
        let name = item[kSENDERNAME] as? String
        let userId = item[kSENDERID] as? String
        
        let date = dateFormatter().date(from: (item[kDATE] as? String)!)
        
        let latitude = item[kLATITUDE] as? Double
        let longitude = item[kLONGITUDE] as? Double
        
        let mediaItem = JSQLocationMediaItem(location: nil)
        
        mediaItem?.appliesMediaViewMaskAsOutgoing = returnOutgoingStatusFromUser(senderId: userId!)
        
        let location = CLLocation(latitude: latitude!, longitude: longitude!)
        
        mediaItem?.setLocation(location, withCompletionHandler: {
            
            self.collectionView.reloadData()
        })
        
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, media: mediaItem)
    }
    
    
    
    //MARK: Helper function
    
//    func imageFromData(item: NSDictionary, result: (_ image: UIImage?) -> Void) {
//        
//        var image: UIImage?
//        
//        let decodedData = NSData(base64Encoded: (item[kPICTURE] as? String)!, options: NSData.Base64DecodingOptions(rawValue: 0))
//        
//        
//        image = UIImage(data: decodedData! as Data)
//        
//        result(image)
//        
//    }
    
    
    
    func returnOutgoingStatusFromUser(senderId: String) -> Bool {
        
        if senderId == FUser.currentUser()!.objectId {
            
            //outgoing
            return true
            
        } else {
            
            //incoming
            return false
        }
        
    }

}
