//
//  NewsTableViewCell.swift
//  stonks
//
//  Created by Samuel Hobel on 2/16/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import UIKit

class NewsTableViewCell: UITableViewCell {

    @IBOutlet weak var heading: UILabel!
    @IBOutlet weak var source: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var paywallIcon: UIImageView!
    @IBOutlet weak var newImage: UIImageView!
    @IBOutlet weak var symbols: UILabel!
    
    public var url:String?
    public var paywall = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //self.layoutIfNeeded()
        newImage.layer.cornerRadius = 10.0
        //newImage.clipsToBounds = true
        newImage.layer.masksToBounds = true
        if self.paywall {
            paywallIcon.isHidden = false
        } else {
            paywallIcon.isHidden = true
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
