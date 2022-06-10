//
//  TopAnalystsTableViewCell.swift
//  stonks
//
//  Created by Samuel Hobel on 2/9/22.
//  Copyright © 2022 Samuel Hobel. All rights reserved.
//

import UIKit

class TopAnalystsTableViewCell: UITableViewCell {

    @IBOutlet weak var totalScore: UILabel!
    @IBOutlet weak var rank: UILabel!
    @IBOutlet weak var symbol: UILabel!
    @IBOutlet weak var numAnalysts: UILabel!
    @IBOutlet weak var avgRank: UILabel!
    @IBOutlet weak var successRateProgress: CircularProgressView!
    @IBOutlet weak var successRate: UILabel!
    @IBOutlet weak var avgPriceTarget: UILabel!
    @IBOutlet weak var lowPriceTarget: UILabel!
    @IBOutlet weak var highPriceTarget: UILabel!
    @IBOutlet weak var freshness: UILabel!
    @IBOutlet weak var numRatings: UILabel!
    @IBOutlet weak var latestPrice: UILabel!
    @IBOutlet weak var fidelityScore: UIImageView!
    @IBOutlet weak var fidelityScoreVal: UILabel!
    @IBOutlet weak var rankborder: UIView!
    
    @IBOutlet weak var numAnalystsIcon: UIImageView! //255 45 85
    @IBOutlet weak var avgRankIcon: UIImageView! //255 204 0
    @IBOutlet weak var targetIcon: UIImageView! //0 122 255
    @IBOutlet weak var freshnessIcon: UIImageView! //52 199 89
    @IBOutlet weak var numRatingsIcon: UIImageView! //175 82 222
    @IBOutlet weak var companyName: UILabel!
    
    public enum IconName {
        case numAnalysts, avgRank, priceTarget, freshness, numRatings
    }
    public var iconDict:[IconName:UIImageView] = [:]
    public var iconColorDict:[IconName:UIColor] = [:]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.iconDict = [
            IconName.numAnalysts: numAnalystsIcon,
            IconName.avgRank: avgRankIcon,
            IconName.priceTarget: targetIcon,
            IconName.freshness: freshnessIcon,
            IconName.numRatings: numRatingsIcon
        ]
        
        self.iconColorDict = [
            IconName.numAnalysts: UIColor(red: 52.0/255.0, green: 199.9/255.0, blue: 89.0/255.0, alpha: 1.0),
            IconName.avgRank: UIColor(red: 52.0/255.0, green: 199.9/255.0, blue: 89.0/255.0, alpha: 1.0),
            IconName.priceTarget: UIColor(red: 52.0/255.0, green: 199.9/255.0, blue: 89.0/255.0, alpha: 1.0),
            IconName.freshness: UIColor(red: 52.0/255.0, green: 199.9/255.0, blue: 89.0/255.0, alpha: 1.0),
            IconName.numRatings: UIColor(red: 52.0/255.0, green: 199.9/255.0, blue: 89.0/255.0, alpha: 1.0)
        ]
        
        self.rankborder.layer.borderWidth = 1.0
        self.rankborder.layer.borderColor = UIColor.white.cgColor
        self.rankborder.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    public func setIconColor(_ iconName:IconName, percent:Double) {
        var perc = percent
        if perc.isNaN {
            perc = 1.0
        }
        let greyColor:Double = 170.0
        let icon = self.iconDict[iconName]
        let iconColor = self.iconColorDict[iconName]
        let cs:[CGFloat] = iconColor!.cgColor.components!
        var components:[CGFloat] = []
        for c in cs {
            components.append(c*255.0)
        }
        let red = components[0] >= greyColor ?
            ((Double(components[0]) - greyColor)*(perc)) + greyColor :
            ((greyColor - Double(components[0]))*(1.0 - perc)) + Double(components[0])
        let green = components[1] >= greyColor ?
            ((Double(components[1]) - greyColor)*(perc)) + greyColor :
        ((greyColor - Double(components[1]))*(1.0 - perc)) + Double(components[1])
        let blue = components[2] >= greyColor ?
            ((Double(components[2]) - greyColor)*(perc)) + greyColor :
        ((greyColor - Double(components[2]))*(1.0 - perc)) + Double(components[2])
        icon?.tintColor = UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1.0)
    }
    

}
