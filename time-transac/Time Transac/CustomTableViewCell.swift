//
//  CustomTableViewCell.swift
//  Time Transac
//
//  Created by Gbenga Ayobami on 2018-01-06.
//  Copyright © 2018 Gbenga Ayobami. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var ratingsView: UIView!
    @IBOutlet weak var fullNameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
