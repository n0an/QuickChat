//
//  Download.swift
//  QuickChat2.0
//
//  Created by David Kababyan on 09/10/2016.
//  Copyright © 2016 David Kababyan. All rights reserved.
//

import Foundation
import FirebaseStorage
import Firebase

let storage = FIRStorage.storage()

//Image
func getImageFromURL(url: String, withBlock: @escaping (_ image: UIImage?) -> Void) {
    
    let url = NSURL(string: url)
    
    let downloadQueue = DispatchQueue(label: "imageDownloadQueue")
    
    downloadQueue.async {
        
        let data = NSData(contentsOf: url! as URL)
        
        let image: UIImage!
        
        if data != nil {
            
            
            image = UIImage(data: data! as Data)
            
            DispatchQueue.main.async {
                
                withBlock(image!)
            }
            
        }
    }
    
}


//video

func uploadVideo(video: NSData, chatRoomId: String, view: UIView, withBlock: @escaping (_ videoLink: String?) -> Void) {
    
    let progressHUD = MBProgressHUD.showAdded(to: view, animated: true)

    progressHUD.mode = .determinateHorizontalBar

    let dateString = dateFormatter().string(from: Date())
    
    let videoFileName = "VideoMessages/" + chatRoomId + "/" + dateString + ".mov"
    
    let storageRef = storage.reference(forURL: kFILEREFERENCE).child(videoFileName)
    
    
    var task : FIRStorageUploadTask!
    
    task = storageRef.put(video as Data, metadata: nil, completion: {
        metadata, error in
        
        task.removeAllObservers()
        progressHUD.hide(animated: true)
        
        if error != nil {
            
            print("error uploading video \(error!.localizedDescription)")
            ProgressHUD.showError(error!.localizedDescription)

            return
        }
        
        
        let link = metadata!.downloadURL()
        withBlock(link?.absoluteString)
        
    })
    
    task.observe(FIRStorageTaskStatus.progress, handler: {
        snapshot in
        progressHUD.progress = Float((snapshot.progress?.completedUnitCount)!) / Float( (snapshot.progress?.totalUnitCount)!)
        
    })
    
    
    
}


func downloadVideo(videoUrl: String, result: @escaping (_ isReadyToPlay: Bool, _ videoFileName: String) -> Void) {
    
    let videoURL = NSURL(string: videoUrl)
    
    let videoFileName = (videoUrl.components(separatedBy: "%").last!).components(separatedBy: "?").first!

    
    if fileExistsAtPath(path: videoFileName) {
        
        result(true, videoFileName)
        
    } else {
        
        let dowloadQueue = DispatchQueue(label: "videoDownloadQueue")
        
        dowloadQueue.async {
            
            let data = NSData(contentsOf: videoURL! as URL)
            
            if data != nil {
                
                var docURL = getDocumentsURL()
                
                docURL = docURL.appendingPathComponent(videoFileName, isDirectory: false)
                
                data!.write(to: docURL, atomically: true)
                
                DispatchQueue.main.async {
                    
                    result(true, videoFileName)
                }
                
            } else {
                ProgressHUD.showError("No Video in database")
            }
        }
    }
    
}

func videoThumbnail(video: NSURL) -> UIImage {
    
    let asset = AVURLAsset(url: video as URL, options: nil)
    
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    imageGenerator.appliesPreferredTrackTransform = true
    
    let time = CMTimeMakeWithSeconds(0.5, 1000)
    var actualTime = kCMTimeZero
    
    var image: CGImage?
    
    
    do {
        image = try imageGenerator.copyCGImage(at: time, actualTime: &actualTime)
    }
    catch let error as NSError {
        print(error.localizedDescription)
    }
    
    let thumbnail = UIImage(cgImage: image!)
    
    return thumbnail
}


//Audio


func uploadAudio(audioPath: String, chatRoomId: String, view: UIView, withBlock: @escaping (_ audioLink: String?) -> Void) {
    
    let progressHUD = MBProgressHUD.showAdded(to: view, animated: true)
    
    progressHUD.mode = .determinateHorizontalBar
    
    let dateString = dateFormatter().string(from: Date())
    
    let audio = NSData(contentsOfFile: audioPath)
    let audioFileName = "AudioMessages/" + chatRoomId + "/" + dateString + ".m4a"
    
    let storageRef = storage.reference(forURL: kFILEREFERENCE).child(audioFileName)
    
    
    var task : FIRStorageUploadTask!
    
    task = storageRef.put(audio as! Data, metadata: nil, completion: {
        metadata, error in
        
        task.removeAllObservers()
        progressHUD.hide(animated: true)
        
        if error != nil {
            
            print("error uploading audio \(error?.localizedDescription)")
            ProgressHUD.showError(error!.localizedDescription)
            return
        }
        
        
        let link = metadata!.downloadURL()
        withBlock(link?.absoluteString)
        
    })
    
    task.observe(FIRStorageTaskStatus.progress, handler: {
        snapshot in
        progressHUD.progress = Float((snapshot.progress?.completedUnitCount)!) / Float( (snapshot.progress?.totalUnitCount)!)
        
    })
    
    
    
}

func downloadAudio(audioUrl: String, result: @escaping (_ audioFileName: String) -> Void) {
    
    

    let audiURL = NSURL(string: audioUrl)
    let audioFileName = (audioUrl.components(separatedBy: "%").last!).components(separatedBy: "?").first!

    if fileExistsAtPath(path: audioFileName) {
        
        result(audioFileName)
    } else {
        
        //start downloading
        
        let downloadQueue = DispatchQueue(label: "audioDownload")
        
        downloadQueue.async {
            
            
            let data = NSData(contentsOf:  audiURL! as URL)
            
            if data != nil {
                
                var docURL = getDocumentsURL()
                
                docURL = docURL.appendingPathComponent(audioFileName, isDirectory: false)
                
                data!.write(to: docURL, atomically: true)
                
                DispatchQueue.main.async {
                    
                    result(audioFileName)
                }
                
                
            } else {
                print("no audio at link")
            }
        }
    }
    
}


//Helper

func fileInDocumentsDirectory(filename: String) -> String {
    
    let fileURL = getDocumentsURL().appendingPathComponent(filename)
    return fileURL.path
}

func getDocumentsURL() -> URL {
    
    let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
    
    return documentURL!
}

func fileExistsAtPath(path: String) -> Bool {
    
    var doesExist = false
    
    let filePath = fileInDocumentsDirectory(filename: path)
    let fileManager = FileManager.default
    
    if fileManager.fileExists(atPath: filePath) {
        doesExist = true
    } else {
        doesExist = false
    }
    
    return doesExist
}







