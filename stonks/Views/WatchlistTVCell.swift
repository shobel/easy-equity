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
    @IBOutlet weak var afterPriceChange: ColoredValueLabel!
    @IBOutlet weak var percentChange: ColoredValueLabel!
    @IBOutlet weak var afterPercentChange: ColoredValueLabel!
    
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
        percentChange.setValue(value: company.quote?.changePercent ?? 0.0, isPercent: true)
        
        daysToEarnings.text = "\(Int.random(in: 1 ..< 30))d"
        let score = ((Double.random(in: 0.0...10.0)*10).rounded())/10
        buyRating.setRatingColor(score: score)
        buyRating.text = "\(score)"
        
        if let quote = company.quote {
            if quote.latestSource == "IEX real time price" {
                afterPriceChange.isHidden = true
                afterPercentChange.isHidden = true
            } else {
                afterPriceChange.isHidden = false
                afterPercentChange.isHidden = false
                var prefix = "After:"
                if isPremarket() {
                    prefix = "Pre:"
                }
                afterPriceChange.setValue(value: quote.extendedPrice - quote.latestPrice, isPercent: false, prefix: prefix)
                afterPercentChange.setValue(value: quote.extendedChangePercent, isPercent: true, prefix: prefix)
            }
        }
    }
    
    private func isPremarket() -> Bool{
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.init(abbreviation: "EST")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = formatter.string(from: now)
        let etDate = formatter.date(from: dateString)
        
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.init(abbreviation: "EST")!
        let nine_thirty = calendar.date(
            bySettingHour: 9,
            minute: 30,
            second: 0,
            of: now)!
        
        if etDate! < nine_thirty {
            return true
        }
        return false
    }
}
