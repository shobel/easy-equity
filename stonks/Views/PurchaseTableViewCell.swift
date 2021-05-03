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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func setupPriceLabel() {
        self.price.layer.shadowColor = UIColor(red: 25.0/255.0, green: 105.0/255.0, blue: 75.0/255.0, alpha: 1.0).cgColor
        self.price.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        self.price.layer.shadowOpacity = 1.0
        self.price.layer.shadowRadius = 0.0
        self.price.layer.masksToBounds = false
//        self.price.clipsToBounds = true
        self.price.layer.cornerRadius = 5.0
    }
}
