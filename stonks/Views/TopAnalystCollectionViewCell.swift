//
//  TopAnalystCollectionViewCell.swift
//  stonks
//
//  Created by Samuel Hobel on 8/21/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import UIKit

class TopAnalystCollectionViewCell: UICollectionViewCell {
 
    @IBOutlet weak var symbol: UILabel!
    @IBOutlet weak var avgUpside: ColoredValueLabel!
    @IBOutlet weak var numAnalysts: UILabel!
    @IBOutlet weak var avgRank: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.cornerRadius = 10.0
    }
}
