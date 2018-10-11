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
        var buy = Int.random(in: 1 ..< 130)
        if buy > 100 {
            buy = 100
        }
        var hold = 0
        var sell = 0
        if buy < 99 {
            hold = Int.random(in: 1 ..< (100 - buy))
            sell = 100 - buy - hold
        }
        buyRating.setRatingColor(buy: Double(buy), hold: Double(hold), sell: Double(sell))
        //buyRating.text = "\(buy)" + " \(hold)" + " \(sell)"
        buyRating.text = "\(buy)"
    }
}
