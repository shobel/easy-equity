//
//  MarketNewsTableViewCell.swift
//  stonks
//
//  Created by Samuel Hobel on 7/24/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import UIKit

class MarketNewsTableViewCell: UITableViewCell {

    @IBOutlet weak var heading: UILabel!
    @IBOutlet weak var source: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var newImage: UIImageView!
    @IBOutlet weak var symbols: UILabel!
    
    public var url:String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //self.layoutIfNeeded()
        newImage.layer.cornerRadius = 10.0
        //newImage.clipsToBounds = true
        newImage.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
