//
//  TweetTableViewCell.swift
//  stonks
//
//  Created by Samuel Hobel on 4/4/22.
//  Copyright © 2022 Samuel Hobel. All rights reserved.
//

import UIKit

class TweetTableViewCell: UITableViewCell {

    @IBOutlet weak var createdAt: UILabel!
    @IBOutlet weak var tweet: UILabel!
    @IBOutlet weak var cashtags: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
