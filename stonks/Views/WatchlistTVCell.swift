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
    @IBOutlet weak var percentChange: ColoredValueLabel!
    @IBOutlet weak var priceChange: ColoredValueLabel!
    
    @IBOutlet weak var preAfterImage: UIImageView!
    @IBOutlet weak var buyRating: RatingLabel!
    @IBOutlet weak var daysToEarnings: UILabel!
    
    @IBOutlet weak var priceChartPreview: PriceChartPreviewView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    public func displayData(company: Company){
        self.priceChartPreview.setup()
        
        ticker.text = company.symbol
        fullName.text = company.fullName
        
        percentChange.setValue(value: (company.quote?.changePercent ?? 0.0) * 100.0, isPercent: true)
        
        currentPrice.alpha = 0.0
        UIView.animate(withDuration: 0.2, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.currentPrice.alpha = 1.0
        }, completion: nil)
        currentPrice.text = String(format: "%.2f", company.quote?.latestPrice ?? "--")
        priceChange.setValue(value: (company.quote?.change ?? 0.0), isPercent: false)
        
        if company.daysToER < 0 {
            daysToEarnings.text = ""
        } else {
            daysToEarnings.text = String(company.daysToER) + "d"
        }
        
        if let score = company.analystsRating?.overallScore {
            buyRating.setRatingColor(score: score)
            buyRating.text = String(format: "%.1f", score)
        } else {
            buyRating.setRatingColor(score: -1)
            buyRating.text = ""
        }
        
        if let quote = company.quote {
            self.priceChartPreview.setData(quote)
            if quote.isUSMarketOpen {
                preAfterImage.isHidden = true
            } else if (quote.extendedPrice != nil && quote.extendedChangePercent != nil){
                preAfterImage.isHidden = false
                preAfterImage.image = UIImage(systemName: "moon.circle.fill")
                preAfterImage.tintColor = .black
                //preAfterImage.image = UIImage(systemName: "sunset")
                if GeneralUtility.isPremarket() {
                    preAfterImage.image = UIImage(systemName: "sun.max.fill")
                    preAfterImage.tintColor = Constants.yellow
                    //preAfterImage.image = UIImage(systemName: "sunrise")
                }
                currentPrice.text = String(format: "%.2f", company.quote?.extendedPrice ?? "--")
                priceChange.setValue(value: quote.extendedChangePercent! * 100.0, isPercent: true, prefix: "")
                //percentChange.setValue(value: (quote.extendedChangePercent ?? 0.0) * 100.0, isPercent: true, prefix: "")
            } else {
                preAfterImage.isHidden = true
            }
        }
    }
    
}
