//
//  TopAnalystCollectionViewCell.swift
//  stonks
//
//  Created by Samuel Hobel on 8/21/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import UIKit

class TopAnalystCollectionViewCell: UICollectionViewCell {
 
    @IBOutlet weak var segueButton: UIButton!
    @IBOutlet weak var symbol: UILabel!
    @IBOutlet weak var avgUpside: ColoredValueLabel!
    @IBOutlet weak var numAnalysts: UILabel!
    @IBOutlet weak var avgRank: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 10
    }
}
