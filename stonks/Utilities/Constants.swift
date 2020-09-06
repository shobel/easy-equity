//
//  Constants.swift
//  stonks
//
//  Created by Samuel Hobel on 9/27/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import Foundation
import UIKit

struct Constants{

    public static var demo = true
    public static var subscriber = false
    
    public static var restorationIDs = (details: "companyDetails", watchlist: "watchlist", search: "companySearch")
    
    public enum TimeIntervals{
        case day, one_month, three_month, six_month, one_year, five_year, twenty_year, max
    }
    
    public enum RatingType {
        case buy, hold
    }
    
    public static var ratingColors:[RatingType:UIColor] = [
        RatingType.buy: lightGreen,
        RatingType.hold: lightOrange
    ]
    public static var veryLightGrey = UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 1.0)
    public static var darkPink = UIColor(red: 234.0/255.0, green: 0.0/255.0, blue: 97.0/255.0, alpha: 1.0)
    public static var fadedDarkPink = UIColor(red: 234.0/255.0, green: 0.0/255.0, blue: 97.0/255.0, alpha: 0.2)
    public static var lightPink = UIColor(red: 255.0/255.0, green: 140.0/255.0, blue: 173.0/255.0, alpha: 1.0)
    public static var purple = UIColor(red: 199.0/255.0, green: 0.0/255.0, blue: 172.0/255.0, alpha: 1.0)
    public static var green = UIColor(red: 9.0/255.0, green: 196.0/255.0, blue: 122.0/255.0, alpha: 1.0)
    public static var yellow = UIColor(red: 230.0/255.0, green: 225.0/255.0, blue: 37.0/255.0, alpha: 1.0)
    public static var blue = UIColor(red: 0.0/255.0, green: 160.0/255.0, blue: 255.0/255.0, alpha: 1.0)

    public static var teal = UIColor(red: 120.0/255.0, green: 255.0/255.0, blue: 180.0/255.0, alpha: 1.0)
    public static var lightGreen = UIColor(red: 115.0/255.0, green: 255.0/255.0, blue: 0.0/255.0, alpha: 1.0)
    public static var orange = UIColor(red: 255.0/255.0, green: 150.0/255.0, blue: 0.0/255.0, alpha: 1.0)
    public static var lightOrange = UIColor(red: 255.0/255.0, green: 240.0/255.0, blue: 183.0/255.0, alpha: 1.0)
    public static var darkGrey = UIColor(red: 67.0/255.0, green: 67.0/255.0, blue: 67.0/255.0, alpha: 1.0)
    public static var darkerGrey = UIColor(red: 31.0/255.0, green: 33.0/255.0, blue: 36.0/255.0, alpha: 1.0)

    public static var fadedOrange = UIColor(red: 255.0/255.0, green: 150.0/255.0, blue: 0.0/255.0, alpha: 0.5)
    public static var fadedPurple = UIColor(red: 150.0/255.0, green: 0.0/255.0, blue: 175.0/255.0, alpha: 0.5)
    public static var fadedBlue = UIColor(red: 0.0/255.0, green: 50.0/255.0, blue: 255.0/255.0, alpha: 0.5)
    public static var fadedTeal = UIColor(red: 50.0/255.0, green: 200.0/255.0, blue: 150.0/255.0, alpha: 0.5)
    public static var fadedDarkGrey = UIColor(red: 67.0/255.0, green: 67.0/255.0, blue: 67.0/255.0, alpha: 0.5)

    /* FINVIZ ratings */
    enum FinvizRatingCategory {
        case buy, weakBuy, hold, weakSell, sell
    }
    
    static var finvizKeywordsDict: [String:FinvizRatingCategory] = [
        "Buy": .buy,
        "Strong Buy": .buy,
        "Top Pick": .buy,
        "Positive": .buy,
        "Weak Buy": .weakBuy,
        "Moderate Buy": .weakBuy,
        "Outperform": .weakBuy,
        "Sector Outperform": .weakBuy,
        "Market Outperform": .weakBuy,
        "Overweight": .weakBuy,
        "Accumulate": .weakBuy,
        "Hold": .hold,
        "Neutral": .hold,
        "Market Perform": .hold,
        "Mkt Perform": .hold,
        "Peer Perform": .hold,
        "In line": .hold,
        "Sector Weight": .hold,
        "Equal Weight": .hold,
        "Weak Sell": .weakSell,
        "Moderate Sell": .weakSell,
        "Underweight": .weakSell,
        "Sector Underperform": .weakSell,
        "Market Underperform": .weakSell,
        "Underperform": .weakSell,
        "Reduce": .weakSell,
        "Negative": .sell,
        "Sell": .sell,
        "Strong Sell": .sell
    ]
    /* END FINVIZ */
    
}
