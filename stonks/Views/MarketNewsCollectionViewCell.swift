//
//  MarketNewsCollectionViewCell.swift
//  stonks
//
//  Created by Samuel Hobel on 10/26/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import UIKit

class MarketNewsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var heading: UILabel!
    @IBOutlet weak var source: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var newImage: UIImageView!
    @IBOutlet weak var symbols: UILabel!
    
    public var url:String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //self.layoutIfNeeded()
        
        self.backgroundColor = Constants.themeDarkBlue
        self.layer.cornerRadius = 10.0
        
        newImage.layer.cornerRadius = 10.0
        //newImage.clipsToBounds = true
        newImage.layer.masksToBounds = true
    }
}
