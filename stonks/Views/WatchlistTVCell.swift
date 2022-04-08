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
    
    @IBOutlet weak var erImage: UIImageView!
    @IBOutlet weak var preAfterImage: UIImageView!
    @IBOutlet weak var preAfterImageWidth: NSLayoutConstraint!
    private var preAfterImageVisibleWidth:CGFloat = CGFloat(15.0)
    @IBOutlet weak var buyRating: RatingLabel!
    @IBOutlet weak var daysToEarnings: UILabel!
    
    @IBOutlet weak var priceChartPreview: PriceChartPreviewView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    public func displayData(company: Company, score:String, percentile:Double){
        self.priceChartPreview.setup()
        
        ticker.text = company.symbol
        fullName.text = company.fullName
        
        percentChange.setValue(value: company.quote?.changePercent ?? 0.0, isPercent: true)
        
        currentPrice.alpha = 0.0
        UIView.animate(withDuration: 0.2, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.currentPrice.alpha = 1.0
        }, completion: nil)
        currentPrice.text = String(format: "%.2f", company.quote?.latestPrice ?? "--")
        priceChange.setValue(value: (company.quote?.change ?? 0.0), isPercent: false)
        
        daysToEarnings.text = ""
        erImage.isHidden = true
        if let ea:Int = company.quote?.daysToEarnings {
            if ea > 0 && ea < 6 {
                erImage.isHidden = false
                daysToEarnings.text = String(ea) + "d"
            }
        }
        
        //scores, arent necessarily the buy ratings
        self.buyRating.backgroundColor = self.getScoreTextColor(percentile).withAlphaComponent(0.2)
        self.buyRating.textColor = self.getScoreTextColor(percentile)
        self.buyRating.text = score
        
        if let quote = company.quote {
            self.priceChartPreview.setData(quote)
            if Dataholder.isUSMarketOpen {
                preAfterImage.isHidden = true
                preAfterImageWidth.constant = 0
            } else if (quote.extendedPrice != nil && quote.extendedPrice != 0.0 && quote.extendedChangePercent != nil && quote.extendedChangePercent != 0.0){
                preAfterImage.isHidden = false
                preAfterImageWidth.constant = self.preAfterImageVisibleWidth
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
    
    //val is number between 0 and 1
    func getScoreTextColor(_ val:Double) -> UIColor {
        if val == -1 {
            return UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0)
        }
        let blue:CGFloat = 0.0
        var red:CGFloat = 0.0
        var green:CGFloat = 0.0
        if val <= 0.5 {
            red = 218.0
            green = CGFloat((val/0.5) * 218.0)
        } else {
            green = 218.0
            red = CGFloat(218.0 - ((val - 0.5)/0.5) * 218.0)
        }
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1.0)
    }
    
}
