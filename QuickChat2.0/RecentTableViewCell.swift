//
//  RecentTableViewCell.swift
//  QuickChat2.0
//
//  Created by David Kababyan on 09/10/2016.
//  Copyright © 2016 David Kababyan. All rights reserved.
//

import UIKit

class RecentTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func bindData(recent: NSDictionary) {
        
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width/2
        avatarImageView.layer.masksToBounds = true
        
        avatarImageView.image = UIImage(named: "avatarPlaceholder")
        
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.5
        
        if (recent[kTYPE] as? String)! == kPRIVATE {

            let withUserId = (recent[kWITHUSERUSERID] as! String)
            
            firebase.child(kUSER).queryOrdered(byChild: kOBJECTID).queryEqual(toValue: withUserId).observe(.value, with: {
                snapshot in
                                
                if snapshot.exists() {
                    
                    let userDictionary = ((snapshot.value as! NSDictionary).allValues as Array).first
                    
                    
                    let fUser = FUser.init(_dictionary: userDictionary as! NSDictionary)

                    if fUser.avatar != "" {
                        
                        imageFromData(pictureData: fUser.avatar, withBlock: { (image) in
                            
                            self.avatarImageView.image = image
                            
                        })

                    }
                    
                }
                
            })
            
        } else if (recent[kTYPE] as? String)! == kGROUP {
            

            firebase.child(kGROUP).queryOrdered(byChild: kGROUPID).queryEqual(toValue: recent[kCHATROOMID] as! String).observe(.value, with: {
                snapshot in
                
                if snapshot.exists() {

                    let userDictionary = ((snapshot.value as! NSDictionary).allValues as Array).first
                    
                    
                    let group = userDictionary as! NSDictionary
                    
                    if group[kAVATAR] as! String != "" {
                        
                        imageFromData(pictureData: group[kAVATAR] as! String, withBlock: { (image) in

                            self.avatarImageView.image = image
                            
                        })

                    }
                    
                }
                
            })

        }
        
        
        nameLabel.text = recent[kWITHUSERUSERNAME] as? String
        
        
        lastMessageLabel.text = DecryptText(chatRoomID: (recent[kCHATROOMID] as? String)!, string: (recent[kLASTMESSAGE] as? String)!)

        counterLabel.text = ""
        
        if (recent[kCOUNTER] as? Int)! != 0 {
            counterLabel.text = "\(recent[kCOUNTER]!) New"
        }
        
        let date = dateFormatter().date(from: recent[kDATE] as! String)
        
        dateLabel.text = timeElapsed(date: date!)
    }

    
    func timeElapsed(date: Date) -> String {
        
        let seconds = NSDate().timeIntervalSince(date)
        
        let elapsed: String?
        
        if seconds < 60 {
            elapsed = "Just Now"
        } else {
            
            let currentDateFormater = dateFormatter()
            currentDateFormater.dateFormat = "dd/MM/YYYY"

            elapsed = "\(currentDateFormater.string(from: date))"
            
        }
        
        return elapsed!
    }
    
    
}
