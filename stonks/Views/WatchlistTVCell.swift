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
    
    public func displayData(company: Company){
        ticker.text = company.ticker
        fullName.text = company.fullName
        
        currentPrice.text = String(format: "%.2f", company.quote?.latestPrice ?? "--")
        
        priceChange.text = String(format: "%.2f", company.quote?.change ?? "--")
        priceChange.textColor = setColor(value: company.quote?.change)
        
        percentChange.text = String(format: "%.2f", company.quote?.changePercent ?? "--") + "%"
        percentChange.textColor = setColor(value: company.quote?.changePercent)
        
        daysToER.text = "\(Int.random(in: 1 ..< 30))d"
    }

    private func setColor(value: Double?) -> UIColor{
        if value == nil {
            return UIColor.black
        }
        
        if value! < 0 {
            return Constants.red
        }
        return Constants.green
    }
}
