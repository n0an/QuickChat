//
//  Audio.swift
//  QuickChat2.0
//
//  Created by David Kababyan on 22/10/2016.
//  Copyright © 2016 David Kababyan. All rights reserved.
//

import Foundation

class Audio {
    
    var delegate: IQAudioRecorderViewControllerDelegate
    
    init(delegate_: IQAudioRecorderViewControllerDelegate) {
        delegate = delegate_
    }
    
    func presentAudioRecorder(target: UIViewController) {
        
        let controller = IQAudioRecorderViewController()
        
        controller.delegate = delegate
        controller.title = "Recorder"
        controller.maximumRecordDuration = kAUDIOMAXDURATION
        controller.allowCropping = true
        target.presentBlurredAudioRecorderViewControllerAnimated(controller)
    }
    
}
