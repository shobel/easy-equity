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
    @IBOutlet weak var bonusIcon: UIImageView!
    @IBOutlet weak var price: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupPriceLabel()
        self.backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func setupPriceLabel() {
        self.price.layer.cornerRadius = 10.0
    }
}
