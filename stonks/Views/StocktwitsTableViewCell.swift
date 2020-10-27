//
//  StocktwitsTableViewCell.swift
//  stonks
//
//  Created by Samuel Hobel on 10/25/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import UIKit

class StocktwitsTableViewCell: UITableViewCell {

    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var message: UITextView!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var bullbear: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
