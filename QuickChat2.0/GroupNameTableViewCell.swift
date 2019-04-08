//
//  GroupNameTableViewCell.swift
//  QuickChat2.0
//
//  Created by David Kababyan on 18/12/2016.
//  Copyright © 2016 David Kababyan. All rights reserved.
//

import UIKit

class GroupNameTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var membersLabel: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func bindData(group: NSDictionary, withMembers: Bool) {
        
        let placeHolderImage = UIImage(named: "Groups")
        
        avatarImageView.image = maskRoundedImage(image: placeHolderImage!, radius: Float(placeHolderImage!.size.width / 2))
        
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.5
        
        
        if group[kAVATAR] as! String != "" {
            
            imageFromData(pictureData: group[kAVATAR] as! String, withBlock: { (image) in
                
                self.avatarImageView.image = maskRoundedImage(image: image!, radius: Float(image!.size.width / 2))

            })
            
        }
        
        nameLabel.text = group[kNAME] as? String
        
        if withMembers {
            
            let membersCount = (group[kMEMBERS] as? [String])!.count
            membersLabel.text = "\(membersCount) members"
        }
    }


}
