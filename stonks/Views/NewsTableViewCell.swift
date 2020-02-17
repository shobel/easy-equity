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
    
    public var paywall = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
