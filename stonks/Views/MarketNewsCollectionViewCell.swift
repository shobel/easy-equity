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
    @IBOutlet weak var paywallIcon: UIImageView!
    @IBOutlet weak var newImage: UIImageView!
    @IBOutlet weak var symbols: UILabel!
    
    public var url:String?
    public var paywall = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //self.layoutIfNeeded()
        
        self.backgroundColor = UIColor.white
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        self.layer.shadowOpacity = 0.2
        self.layer.shadowRadius = 2.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.cornerRadius = 10.0
        
        newImage.layer.cornerRadius = 10.0
        //newImage.clipsToBounds = true
        newImage.layer.masksToBounds = true
        if self.paywall {
            paywallIcon.isHidden = false
        } else {
            paywallIcon.isHidden = true
        }
    }
}
