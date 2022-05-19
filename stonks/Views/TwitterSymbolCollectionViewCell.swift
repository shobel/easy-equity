//
//  TwitterSymbolCollectionViewCell.swift
//  stonks
//
//  Created by Samuel Hobel on 4/4/22.
//  Copyright © 2022 Samuel Hobel. All rights reserved.
//

import UIKit

class TwitterSymbolCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var symbol: UILabel!
    @IBOutlet weak var tweetCount: UILabel!
    @IBOutlet weak var face: UIImageView!
    @IBOutlet weak var sentiment: UILabel!
    @IBOutlet weak var mainView: UIView!
    
    var parentView:TwitterAccountTableViewCell?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderWidth = 0.0
        self.layer.cornerRadius = 10.0
    }
    
    @IBAction func symbolTapped(_ sender: Any) {
        self.parentView?.symbolTapped(self.symbol.text ?? "")
    }
}
