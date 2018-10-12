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
    @IBOutlet weak var afterPrice: UILabel!
    @IBOutlet weak var priceChange: ColoredPercentLabel!
    @IBOutlet weak var afterPercent: ColoredPercentLabel!
    
    @IBOutlet weak var buyRating: RatingLabel!
    @IBOutlet weak var daysToEarnings: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    public func displayData(company: Company){
        ticker.text = company.ticker
        fullName.text = company.fullName
        
        currentPrice.text = String(format: "%.2f", company.quote?.latestPrice ?? "--")
        priceChange.setPriceChange(percent: company.quote?.changePercent ?? 0.0)
        
        daysToEarnings.text = "\(Int.random(in: 1 ..< 30))d"
        let score = ((Double.random(in: 0.0...10.0)*10).rounded())/10
        buyRating.setRatingColor(score: score)
        buyRating.text = "\(score)"
    }
}
