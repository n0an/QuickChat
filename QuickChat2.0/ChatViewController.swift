//
//  ChatViewController.swift
//  QuickChat2.0
//
//  Created by David Kababyan on 15/10/2016.
//  Copyright © 2016 David Kababyan. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class ChatViewController: JSQMessagesViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, IQAudioRecorderViewControllerDelegate {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let chatRef = firebase.child(kMESSAGE)
    let typingRef = firebase.child(kTYPINGPATH)
    
    var loadCount = 0
    var typingCounter = 0

    
    var max = 0
    var min = 0
    
    var messages: [JSQMessage] = []
    var objects: [NSDictionary] = []
    var loaded: [NSDictionary] = []
    
    var avatarImagesDictionary: NSMutableDictionary?
    var avatarDictionary: NSMutableDictionary?
    
    var members: [String] = []
    var withUsers: [FUser] = []
    var titleName: String?
    
    var chatRoomId: String!
    var isGroup: Bool?
    
    var initialLoadComplete: Bool = false
    var showAvatars = true
    var firstLoad: Bool?
    
    
    var outgouingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
 
//    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
//    
//    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupBubbleImages()
        
        avatarDictionary = [ : ]
        
        updateUI()
        
        clearRecentCounter(chatRoomID: chatRoomId)
        
        loadUserDefaults()
        setBackgroundColor()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backArrow"), style: .plain, target: self, action: #selector(ChatViewController.backAction))

        
        self.senderId = FUser.currentUser()!.objectId
        self.senderDisplayName = FUser.currentUser()!.firstname
        
        self.title = titleName
        
        collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        // FIXING ISSUE WITH SOUND TO HEADPHONES OR SPEAKER
        do {
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
        } catch {
            
        }
        
        
        loadMessegas()
        
        

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        
        super.viewWillAppear(animated)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        clearRecentCounter(chatRoomID: chatRoomId)
        

    }
    
    
    // MARK: - BUBBLES FOR MESSAGES
    func setupBubbleImages() {
        
        let factory = JSQMessagesBubbleImageFactory()
        
        self.outgouingBubbleImageView = factory?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
        
        self.incomingBubbleImageView = factory?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
        
    }
    
    
    
    func backAction() {
        clearRecentCounter(chatRoomID: chatRoomId)
        chatRef.child(chatRoomId).removeAllObservers()
        typingRef.child(chatRoomId).removeAllObservers()
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: JSQMessages Data Source functions
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        let data = messages[indexPath.row]
        
        if data.senderId == FUser.currentUser()!.objectId {
            
            cell.textView?.textColor = UIColor.white
            
        } else {
            
            cell.textView?.textColor = UIColor.black
        }
        
        return cell
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        
        let data = messages[indexPath.row]
        
        return data
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return messages.count
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let data = messages[indexPath.row]
        if data.senderId == FUser.currentUser()!.objectId {
            return self.outgouingBubbleImageView
        } else {
            return self.incomingBubbleImageView
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        
        if indexPath.item % 3 == 0 {
            
            let message = messages[indexPath.item]
            
            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
        }
        
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        
        if indexPath.item % 3 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
        return 0.0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        
        let message = objects[indexPath.row]
        
        let status = message[kSTATUS] as! String
        
        if indexPath.row == (messages.count - 1) {
            
            return NSAttributedString(string: status)
        } else {
            return NSAttributedString(string: "")
        }
        
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        
        if outgoing(item: objects[indexPath.row]) {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        } else {
            return 0.0
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        let message = messages[indexPath.row]
        
        var avatar: JSQMessageAvatarImageDataSource
        
        if let testAvatar = avatarDictionary!.object(forKey: message.senderId) {
            avatar = testAvatar as! JSQMessageAvatarImageDataSource
        } else {
            avatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "avatarPlaceholder"), diameter: 70)
        }
        
        return avatar
        
        
    }
    
    
    //MARK: JSQMesages Delegate functions
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        if text != "" {
            
            sendMessage(text: text, date: date, picture: nil, location: nil, video: nil, audio: nil)
        }
        
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {

        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let camera = Camera(delegate_: self)
        let audioVC = Audio(delegate_: self)
        
        
        let takePhotoOrVideo = UIAlertAction(title: "Camera", style: .default) { (alert: UIAlertAction!) in
            
            camera.PresentMultyCamera(target: self, canEdit: true)
            
        }
        
        let sharePhoto = UIAlertAction(title: "Photo Library", style: .default) { (alert: UIAlertAction!) in
            
            camera.PresentPhotoLibrary(target: self, canEdit: true)
            
        }
        
        let shareVideo = UIAlertAction(title: "Video Library", style: .default) { (alert: UIAlertAction!) in
            
            camera.PresentVideoLibrary(target: self, canEdit: true)
            
        }
        
        let audioMessage = UIAlertAction(title: "Audio Message", style: .default) { (alert: UIAlertAction!) in
            
            audioVC.presentAudioRecorder(target: self)
            
        }
        
        let shareLocation = UIAlertAction(title: "Share Location", style: .default) { (alert: UIAlertAction!) in
            
            if self.haveAccessToUserLocation() {
                self.sendMessage(text: nil, date: Date(), picture: nil, location: kLOCATION, video: nil, audio: nil)
            }
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert: UIAlertAction!) in
    
        }
        
        
        optionMenu.addAction(takePhotoOrVideo)
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(shareVideo)
        optionMenu.addAction(audioMessage)
        optionMenu.addAction(shareLocation)
        optionMenu.addAction(cancelAction)

        self.present(optionMenu, animated: true, completion: nil)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        
        loadMore(maxNumber: max, minNumber: min)
        self.collectionView!.reloadData()
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapAvatarImageView avatarImageView: UIImageView!, at indexPath: IndexPath!) {
        
        let senderId = messages[indexPath.item].senderId
        var selectedUser: FUser?
        
        
        if senderId == FUser.currentId() {
            
            selectedUser = FUser.currentUser()
            
        } else {
            
            for user in withUsers {
                
                if user.objectId == senderId {
                    
                    selectedUser = user
                }
            }

        }
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        
        vc.user = selectedUser!
        
        self.present(vc, animated: true, completion: nil)

        
    }
    
    //MARK: Send Message
    
    func sendMessage(text: String?, date: Date, picture: UIImage?, location: String?, video: NSURL?, audio: String?) {
        
        var outgoingMessage: OutgoingMessage?
        
        
        //text message
        if let text = text {
            
            let encryptedText = EncryptText(chatRoomID: chatRoomId, string: text)
            
            outgoingMessage = OutgoingMessage(message: encryptedText, senderId: FUser.currentUser()!.objectId, senderName: FUser.currentUser()!.firstname, date: date, status: kDELIVERED, type: kTEXT)
        }
        
        //send picture message
        if let pic = picture {
         
            let imageData = UIImageJPEGRepresentation(pic, 0.5)
            let encryptedText = EncryptText(chatRoomID: chatRoomId, string: kPICTURE)
            
            outgoingMessage = OutgoingMessage(message: encryptedText, pictureData: imageData! as NSData, senderId: FUser.currentUser()!.objectId, senderName: FUser.currentUser()!.firstname, date: date, status: kDELIVERED, type: kPICTURE)
            
        }
        
        
        //send video
        if let video = video {
            
            let videoData = NSData(contentsOfFile: video.path!)
            
            let picture = videoThumbnail(video: video)
            let squared = squareImage(image: picture, size: 320)
            let dataThumbnail = UIImageJPEGRepresentation(squared, 0.3)
            
            uploadVideo(video: videoData!, chatRoomId: chatRoomId, view: (self.navigationController?.view)!, withBlock: { (videoLink) in
                
                let encryptedText = EncryptText(chatRoomID: self.chatRoomId, string: kVIDEO)
                
                
                outgoingMessage = OutgoingMessage(message: encryptedText, video: videoLink!, thumbnail: dataThumbnail! as NSData, senderId: FUser.currentUser()!.objectId, senderName: FUser.currentUser()!.firstname, date: date, status: kDELIVERED, type: kVIDEO)
                
                
                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                self.finishSendingMessage()
                
                outgoingMessage?.sendMessage(chatRoomID: self.chatRoomId, item: outgoingMessage!.messageDictionary)
                
            })
            
            return
            
        }
        
        
        //send auidio
        if let audioPath = audio {
            
            uploadAudio(audioPath: audioPath, chatRoomId: chatRoomId, view: (self.navigationController?.view)!, withBlock: { (audioLink) in

                let encryptedText = EncryptText(chatRoomID: self.chatRoomId, string: kAUDIO)
                
                outgoingMessage = OutgoingMessage(message: encryptedText, audio: audioLink!, senderId: FUser.currentUser()!.objectId, senderName: FUser.currentUser()!.firstname, date: date, status: kDELIVERED, type: kAUDIO)
                
                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                self.finishSendingMessage()
                
                outgoingMessage!.sendMessage(chatRoomID: self.chatRoomId, item: outgoingMessage!.messageDictionary)
                
            })
            
            return
            
        }
        
        //send location message
        if let location = location {
            
            let lat: NSNumber = NSNumber(value: appDelegate.coordinates!.latitude)
            let long: NSNumber = NSNumber(value: appDelegate.coordinates!.longitude)
            
            let encryptedText = EncryptText(chatRoomID: chatRoomId, string: kLOCATION)
            
            outgoingMessage = OutgoingMessage(message: encryptedText, latitude: lat, longitude: long, senderId: FUser.currentUser()!.objectId, senderName: FUser.currentUser()!.firstname, date: date, status: kDELIVERED, type: kLOCATION)
            
        }
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        self.finishSendingMessage()
        
        outgoingMessage!.sendMessage(chatRoomID: chatRoomId, item: outgoingMessage!.messageDictionary)
    }
    
    
    //MARK: Responds to collection view tap events
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        
        let object = objects[indexPath.row]
        
        //picture
        if object[kTYPE] as! String == kPICTURE {
            
            let message = messages[indexPath.row]
            
            let mediaItem = message.media as! JSQPhotoMediaItem
            
            let photos = IDMPhoto.photos(withImages: [mediaItem.image])
            
            let browser = IDMPhotoBrowser(photos: photos)
            
            self.present(browser!, animated: true, completion: nil)
            
        }
        
        //location
        if object[kTYPE] as! String == kLOCATION {
            
            let message = messages[indexPath.row]
            
            let mediaItem = message.media as! JSQLocationMediaItem
            
            let mapView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
            
            mapView.location = mediaItem.location
            self.present(mapView, animated: true, completion: nil)

        }

        
        //video
        if object[kTYPE] as! String == kVIDEO {
            
            let message = messages[indexPath.row]
            
            let mediaItem = message.media as! VideoMessage
            
            let player = AVPlayer(url: mediaItem.fileURL! as URL)
            let moviePlayer = AVPlayerViewController()
            
            moviePlayer.player = player
            
            self.present(moviePlayer, animated: true, completion: { 
                moviePlayer.player!.play()
            })
        }

        //audio
        if object[kTYPE] as! String == kAUDIO {
            
            let message = messages[indexPath.row]
            
            let mediaItem = message.media as! AudioMessage
            
            let player = AVPlayer(url: mediaItem.fileURL! as URL)
            let moviePlayer = AVPlayerViewController()
            
            moviePlayer.player = player
            
            self.present(moviePlayer, animated: true, completion: {
                moviePlayer.player!.play()
            })

        }

        
        
        
    }
    
    //MARK: Load Messages
    
    func loadMessegas() {
        
        createTypingObservers()
        
        let legitTypes = [kAUDIO, kVIDEO, kTEXT, kLOCATION, kPICTURE]
        
        
        chatRef.child(chatRoomId).observe(.childAdded, with: {
            snapshot in
            
            //update UI
            
            if snapshot.exists() {
                
                let item = (snapshot.value as? NSDictionary)!
                
                if let type = item[kTYPE] as? String {
                    
                    
                    if legitTypes.contains(type) {
                        
                        if self.initialLoadComplete {
                            
                            let incoming = self.insertMessage(item: item)
                            
                            if incoming {
                                
                                JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
                                
                            }
                            
                            self.finishReceivingMessage()
                            
                        } else {
                            
                            self.loaded.append(item)
                        }
                    }
                }
            }
        })
        
        
        chatRef.child(chatRoomId).observe(.childChanged, with: {
            snapshot in
            
            self.updateMessage(item: snapshot.value as! NSDictionary)
            
        })
        
        chatRef.child(chatRoomId).observeSingleEvent(of: .value, with: {
            snapshot in
            
            self.insertMessages()
            self.finishReceivingMessage(animated: false)
            self.initialLoadComplete = true
            
        })
        
    }
    
    func updateMessage(item: NSDictionary) {
        
        for index in 0 ..< objects.count {
            
            let temp = objects[index]
            
            if item[kMESSAGEID] as! String == temp[kMESSAGEID] as! String {
                
                objects[index] = item
                self.collectionView!.reloadData()
            }
        }
        
    }
    
    func insertMessages() {
        
        max = loaded.count - loadCount
        min = max - kNUMBEROFMESSAGES
        
        
        if min < 0 {
            min = 0
        }
        
        for i in min ..< max {
            
            let item = loaded[i]
            self.insertMessage(item: item)
            loadCount += 1
        }
        
        self.showLoadEarlierMessagesHeader = (loadCount != loaded.count)
    }
    
    
    func loadMore(maxNumber: Int, minNumber: Int) {
        
        max = minNumber - 1
        min = max - kNUMBEROFMESSAGES
        
        if min < 0 {
            
            min = 0
        }
        
        for i in (min ... max).reversed() {
            
            let item = loaded[i]
            self.insertNewMessage(item: item)
            loadCount += 1
        }
        
        self.showLoadEarlierMessagesHeader = (loadCount != loaded.count)
        
    }
    
    func insertNewMessage(item: NSDictionary) -> Bool {
        
        let incomingMessage = IncomingMessage(collectionView_: self.collectionView!)
        
        let message = incomingMessage.createMessage(dictionary: item, chatRoomID: chatRoomId)
        
        objects.insert(item, at: 0)
        messages.insert(message!, at: 0)
        
        return incoming(item: item)
    }
    

    func insertMessage(item: NSDictionary) -> Bool {
        
        let incomingMessage = IncomingMessage(collectionView_: self.collectionView!)
        
        if (item[kSENDERID] as! String) != FUser.currentUser()!.objectId {
            
            updateChatStatus(chat: item, chatRoomId: chatRoomId)
        }
        
        let message = incomingMessage.createMessage(dictionary: item, chatRoomID: chatRoomId)

        objects.append(item)
        messages.append(message!)
        
        return incoming(item: item)
        
    }

    
    func incoming(item: NSDictionary) -> Bool {
        
        if FUser.currentUser()!.objectId == item[kSENDERID] as! String {
            return false
        } else {
            return true
        }
    }
    
    func outgoing(item: NSDictionary) -> Bool {
        
        if FUser.currentUser()!.objectId == item[kSENDERID] as! String {
            
            return true
        } else {
            return false
        }
        
    }
    

    //MARK: UIImagepickerController delegate function
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let video = info[UIImagePickerControllerMediaURL] as? NSURL
        let picture = info[UIImagePickerControllerEditedImage] as? UIImage
        
        sendMessage(text: nil, date: Date(), picture: picture, location: nil, video: video, audio: nil)
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    //MARK: Location access
    
    func haveAccessToUserLocation() -> Bool {
        
        if let _ = appDelegate.locationManager {
            
            return true
        } else {
            
            ProgressHUD.showError("Please give access to location in Settings.")
            return false
        }
        
    }
    
    //MARK: IQAudioRecorder delegate
    
    func audioRecorderController(_ controller: IQAudioRecorderViewController, didFinishWithAudioAtPath filePath: String) {
        
        controller.dismiss(animated: true, completion: nil)
        self.sendMessage(text: nil, date: Date(), picture: nil, location: nil, video: nil, audio: filePath)
        
    }
    
    func audioRecorderControllerDidCancel(_ controller: IQAudioRecorderViewController) {
        
        controller.dismiss(animated: true, completion: nil)
        print("canceled audio")
    }
    
    //MARK: Helper functions
    
    func updateUI() {
        
        if members.count < 3 {
            
            let callButton = UIBarButtonItem(image: UIImage(named: "Phone"), style: UIBarButtonItemStyle.plain, target: self, action: #selector (ChatViewController.callBarButtonPressed))
            
            self.navigationItem.rightBarButtonItem = callButton
        }
        
        getWithUserFromRecent(members: members) { (withUsers) in
            self.withUsers = withUsers
            self.getAvatars()
        }
        
    }
    
    
    func getAvatars() {

        if showAvatars {
            collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSize(width: 30, height: 30)
            collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSize(width: 30, height: 30)
            
            avatarImageFromFUser(user: FUser.currentUser()!)
            
            for user in withUsers {

                avatarImageFromFUser(user: user)
            }
            
            createAvatars(avatars: avatarImagesDictionary)
        }
        
    }
    
    func createAvatars(avatars: NSMutableDictionary?) {
        
        let defaultAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "avatarPlaceholder"), diameter: 70)
        
        if let avat = avatars {
            
            
            for userId in members {
                
                if let avatarImage = avat[userId] {
                    
                    let jsqAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(data: avatarImage as! Data), diameter: 70)
                    
                    self.avatarDictionary!.setValue(jsqAvatar, forKey: userId)
                } else {
                    
                    self.avatarDictionary!.setValue(defaultAvatar, forKey: userId)
                }
                
            }
            
            self.collectionView.reloadData()
        }
        
    }
    
    
    func avatarImageFromFUser(user: FUser) {
        
        if user.avatar != "" {

            imageFromData(pictureData: user.avatar, withBlock: { (image) in
                
                let imageData = UIImageJPEGRepresentation(image!, 0.5)
                
                if self.avatarImagesDictionary != nil {
                    
                    self.avatarImagesDictionary!.removeObject(forKey: user.objectId)
                    self.avatarImagesDictionary!.setObject(imageData!, forKey: user.objectId as NSCopying)
                    
                } else {
                    self.avatarImagesDictionary = [user.objectId : imageData!]
                }
                
                
                self.createAvatars(avatars: self.avatarImagesDictionary)
                
            })

        }
        
        
    }
    
    
    func getWithUserFromRecent(members: [String], result: @escaping (_ withUsers: [FUser]) -> Void) {
        
        var receivedMembers: [FUser] = []
        
        for userId in members {
            
            if userId != FUser.currentUser()!.objectId {

                firebase.child(kUSER).queryOrdered(byChild: kOBJECTID).queryEqual(toValue: userId).observe(.value, with: {
                    snapshot in
                    
                    if snapshot.exists() {
                        
                        let userDictionary = ((snapshot.value as! NSDictionary).allValues as Array).first
                        
                        let fUser = FUser.init(_dictionary: userDictionary as! NSDictionary)
                        
                        receivedMembers.append(fUser)

                        if receivedMembers.count == (members.count - 1) {
                            
                            result(receivedMembers)
                        }

                        
                    }
                    
                })

            }
        }
    }
    
    
    //MARK: UserDefaults
    
    func loadUserDefaults() {
        
        firstLoad = userDefaults.bool(forKey: kFIRSTRUN)
        
        if !firstLoad! {
            
            userDefaults.set(true, forKey: kFIRSTRUN)
            userDefaults.set(showAvatars, forKey: kAVATARSTATE)
            
            userDefaults.set(1.0, forKey: kRED)
            userDefaults.set(1.0, forKey: kGREEN)
            userDefaults.set(1.0, forKey: kBLUE)

            userDefaults.synchronize()
        }
        
        showAvatars = userDefaults.bool(forKey: kAVATARSTATE)
    }
    
    func setBackgroundColor() {
        
        self.collectionView.backgroundColor = UIColor(red: CGFloat(userDefaults.float(forKey: kRED)), green: CGFloat(userDefaults.float(forKey: kGREEN)), blue: CGFloat(userDefaults.float(forKey: kBLUE)), alpha: 1)
        
//        self.collectionView.backgroundColor = UIColor.white

    }

    //MARK: CallFunctions
    
    func callClient() -> SINCallClient {
        
        return appDelegate._client.call()
    }
    
    func callBarButtonPressed() {
        
        let userToCallId = withUsers.first!.objectId as String
        let call = callClient().callUser(withId: userToCallId)
        
        let callVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CallVC") as! CallViewController
        
        callVC._call = call
        
        self.present(callVC, animated: true, completion: nil)
        
        
        
        
    }
    
    //MARK: Typing indicator
    
    
    func createTypingObservers() {
        

        typingRef.child(chatRoomId).observe(.childChanged, with: {
            snapshot in
            
            if snapshot.key != FUser.currentId() {
                
                let typing = snapshot.value as! Bool
                self.showTypingIndicator = typing
                
                if typing {
                    
                    self.scrollToBottom(animated: true)
                }
            }
        })
        
    }
    

    func typingIndicatorStart() {
        
        typingCounter += 1
        typingIndicatorSave(typing: true)
        
        self.perform(#selector(ChatViewController.typingIndicatorStop), with: nil, afterDelay: 2.0)
    }
    
    func typingIndicatorStop() {
        
        typingCounter -= 1
        
        if typingCounter == 0 {
            
            typingIndicatorSave(typing: false)
        }
    }
    
    func typingIndicatorSave(typing: Bool) {
        
        typingRef.child(chatRoomId).updateChildValues([FUser.currentId() : typing])

    }

    
    //MARK:  UITextViewDelegate
    
    override func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        typingIndicatorStart()
        return true
        
    }

    
    



}
