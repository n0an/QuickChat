//
//  CallViewController.swift
//  QuickChat2.0
//
//  Created by David Kababyan on 12/11/2016.
//  Copyright © 2016 David Kababyan. All rights reserved.
//

import UIKit

class CallViewController: UIViewController, SINCallDelegate {

    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var speakerButton: UIButton!
    
    @IBOutlet weak var remoteUsernameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var declineButton: UIButton!
    @IBOutlet weak var endCallButton: UIButton!
    @IBOutlet weak var answerButton: UIButton!
    
    var speaker = false
    var muted = false

    
    var durationTimer: Timer! = nil
    var _call: SINCall!
    
    var callAnswered = false
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    
        _call.delegate = self
        
        if _call.direction == SINCallDirection.incoming {
            
            setCallStatusText(text: "")
            showButtons()
            
            audioController().startPlayingSoundFile(self.pathForSound(soundName: "incoming"), loop: true)
            
        } else {
            
            callAnswered = true
            setCallStatusText(text: "Calling...")
            showButtons()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.remoteUsernameLabel.text = "Unknown"
        
        let id = _call.remoteUserId
        
        userDataFromCallerId(callerId: id!) { (userName, avatarImage) in
            
            self.remoteUsernameLabel.text = userName!
            self.avatarImageView.image = maskRoundedImage(image: avatarImage!, radius:  Float(avatarImage!.size.width / 2))

        }
    }
    
    
    
    func audioController() -> SINAudioController {
        
        return appDelegate._client.audioController()
    }
    
    func setCall(call: SINCall) {
        
        _call = call
        _call.delegate = self
    }
    

    //MARK: IBActions
    
    @IBAction func declineButtonPressed(_ sender: Any) {
        
        _call.hangup()
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func hangUpButtonPressed(_ sender: Any) {
        
        _call.hangup()
        self.dismiss(animated: true, completion: nil)

    }
    
    @IBAction func acceptButtonPressed(_ sender: Any) {
        
        callAnswered = true
        showButtons()
        audioController().stopPlayingSoundFile()
        _call.answer()
    }
    

    @IBAction func speakerButtonPressed(_ sender: Any) {
        
        if !speaker {
            speaker = true
            audioController().enableSpeaker()
            
            speakerButton.setImage(UIImage(named: "speakerSelected"), for: .normal)
            
        } else {
            speaker = false
            audioController().disableSpeaker()
            
            speakerButton.setImage(UIImage(named: "speaker"), for: .normal)
            
        }
        

    }
    
    @IBAction func muteButtonPressed(_ sender: Any) {
        
        if muted {
            muted = false
            audioController().unmute()
            
            muteButton.setImage(UIImage(named: "mute"), for: .normal)
            
        } else {
            muted = true
            audioController().mute()
            muteButton.setImage(UIImage(named: "muteSelected"), for: .normal)
        }
    }
    
    
    //MARK: SINCallDelegate
    
    
    func callDidProgress(_ call: SINCall!) {
        
        setCallStatusText(text: "Ringing...")
        audioController().startPlayingSoundFile(pathForSound(soundName: "ringback"), loop: true)
        
    }
    
    func callDidEstablish(_ call: SINCall!) {
        
        startCallDurationTimer()
        
        showButtons()
        audioController().stopPlayingSoundFile()
        
    }
    
    func callDidEnd(_ call: SINCall!) {
        
        audioController().stopPlayingSoundFile()
        stopCallDurationTimer()
        dismiss(animated: true, completion: nil)
    }
    

    
    //MARK: UIupdates
    
    func setCallStatusText(text: String) {
        
        statusLabel.text = text
    }
    
    func showButtons() {
        
        if callAnswered {
            
            declineButton.isHidden = true
            endCallButton.isHidden = false
            answerButton.isHidden = true
            muteButton.isHidden = false
            speakerButton.isHidden = false

        } else {
            
            declineButton.isHidden = false
            endCallButton.isHidden = true
            answerButton.isHidden = false
            muteButton.isHidden = true
            speakerButton.isHidden = true

        }
        
    }
    
    //MARK: HelperFunction
    
    func pathForSound(soundName: String) -> String {
        
        return Bundle.main.path(forResource: soundName, ofType: "wav")!
    }
    
    
    //MARK: Timer
    
    func onDurationTimer() {
        
        let duration = Date().timeIntervalSince(_call.details.establishedTime)
        updateTimerLabel(seconds: Int(duration))
    }
    
    func updateTimerLabel(seconds: Int) {
        
        let min = String(format: "%02d", (seconds / 60))
        let sec = String(format: "%02d", (seconds % 60))
        
        setCallStatusText(text: "\(min) : \(sec)")
    }
    
    func startCallDurationTimer() {
        
        self.durationTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.onDurationTimer), userInfo: nil, repeats: true)
    }

    func stopCallDurationTimer() {
        
        if durationTimer != nil {
            
            durationTimer.invalidate()
            durationTimer = nil
        }
    }
    

    
    


}
