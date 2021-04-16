//
//  PurchaseTableViewCell.swift
//  stonks
//
//  Created by Samuel Hobel on 4/15/21.
//  Copyright © 2021 Samuel Hobel. All rights reserved.
//

import UIKit
import EFCountingLabel

class PurchaseTableViewCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var credits: EFCountingLabel!
    @IBOutlet weak var price: EFCountingLabel!
    @IBOutlet weak var bonusIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
