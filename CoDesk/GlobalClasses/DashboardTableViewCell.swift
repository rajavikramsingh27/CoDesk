//
//  DashboardTableViewCell.swift
//  CoDesk
//
//  Created by iOS-Appentus on 20/May/2020.
//  Copyright © 2020 iOS-Appentus. All rights reserved.
//

import UIKit

class DashboardTableViewCell: UITableViewCell {
    @IBOutlet weak var imgProfile:UIImageView!
    @IBOutlet weak var lblUserName:UILabel!
    @IBOutlet weak var lblPost:UILabel!
    @IBOutlet weak var btnHeart:UIButton!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imgProfile.layer.cornerRadius = imgProfile.frame.size.height/2
        imgProfile.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
