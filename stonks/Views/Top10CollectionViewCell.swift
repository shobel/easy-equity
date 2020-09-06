//
//  Top10CollectionViewCell.swift
//  stonks
//
//  Created by Samuel Hobel on 7/23/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import UIKit

class Top10CollectionViewCell: UICollectionViewCell {
 
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var changePercentLabel: ColoredValueLabel!
    @IBOutlet weak var latestPriceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 10
    }
    
}
