//
//  WatchlistTVCell.swift
//  stonks
//
//  Created by Samuel Hobel on 9/28/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import UIKit

class WatchlistTVCell: UITableViewCell {

    @IBOutlet weak var ticker: UILabel!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var currentPrice: UILabel!
    @IBOutlet weak var priceChange: UILabel!
    @IBOutlet weak var percentChange: UILabel!
    @IBOutlet weak var daysToER: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
