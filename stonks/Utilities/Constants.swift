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
    
    public static var restorationIDs = (details: "companyDetails", watchlist: "watchlist", search: "companySearch")
    
    public enum TimeIntervals{
        case day, one_month, three_month, six_month, one_year, five_year
    }
    
    public enum RatingType {
        case buy, hold
    }
    
    public static var premiumPackageIds = (
        PREMIUM_KAVOUT_KSCORE: "PREMIUM_KAVOUT_KSCORE",
        PREMIUM_BRAIN_LANGUAGE_METRICS_ALL: "PREMIUM_BRAIN_LANGUAGE_METRICS_ALL",
        PREMIUM_BRAIN_RANKING_21_DAYS: "PREMIUM_BRAIN_RANKING_21_DAYS",
        PREMIUM_BRAIN_SENTIMENT_30_DAYS: "PREMIUM_BRAIN_SENTIMENT_30_DAYS",
        STOCKTWITS_SENTIMENT: "STOCKTWITS_SENTIMENT",
        PREMIUM_PRECISION_ALPHA_PRICE_DYNAMICS: "PREMIUM_PRECISION_ALPHA_PRICE_DYNAMICS",
        TOP_ANALYSTS_SCORES: "TOP_ANALYSTS_SCORES",
        EXTRACT_ALPHA_CROSS_ASSET_MODEL: "EXTRACT_ALPHA_CROSS_ASSET_MODEL",
        EXTRACT_ALPHA_TACTICAL_MODEL: "EXTRACT_ALPHA_TACTICAL_MODEL"
        
    )
    
    public static var premiumPackageNames = [
        "PREMIUM_KAVOUT_KSCORE": "Kavout Kscore",
        "PREMIUM_BRAIN_LANGUAGE_METRICS_ALL": "BRAIN Language Metrics",
        "PREMIUM_BRAIN_RANKING_21_DAYS": "21 Day BRAIN Ranking",
        "PREMIUM_BRAIN_SENTIMENT_30_DAYS": "30 Day BRAIN Sentiment",
        "STOCKTWITS_SENTIMENT": "Stocktwits Sentiment",
        "PREMIUM_PRECISION_ALPHA_PRICE_DYNAMICS": "Precision Alpha Price Dynamics",
        "TOP_ANALYSTS_SCORES": "Top Analyst Upside",
        "EXTRACT_ALPHA_CROSS_ASSET_MODEL": "Extract Alpha Cross-Asset Model",
        "EXTRACT_ALPHA_TACTICAL_MODEL": "Extract Alpha Tactical Model"
    ]
    
    public static var nonPremiumScoreIds = [
        "USER_CUSTOMIZED": "User customized",
        "ANALYST_RECOMMENDATIONS": "Analyst Recommendations",
        "ANALYST_PRICE_TARGET_UPSIDE": "Analyst Price Target Upside"
    ]
    
    public static var ratingColors:[RatingType:UIColor] = [
        RatingType.buy: lightGreen,
        RatingType.hold: lightOrange
    ]
    
    //theme colors
    //blue 12, 8, 28 super dark
    //blue 19, 13, 46 is dark
    //blue is 28, 20, 67 lighter
    //pink 51, 17, 71 is even darker
    //pink 65, 22, 91 is darker
    //pink 73, 22, 91 is lighter
    
    public static var themeBlue = UIColor(red: 19.0/255.0, green: 13.0/255.0, blue: 46.0/255.0, alpha: 1.0)
    //bit lighter
    public static var themeBlue2 = UIColor(red: 28.0/255.0, green: 18.0/255.0, blue: 64.0/255.0, alpha: 1.0)
    public static var themeDarkBlue = UIColor(red: 17.0/255.0, green: 11.0/255.0, blue: 42.0/255.0, alpha: 1.0)
    public static var themePurple = UIColor(red: 51.0/255.0, green: 17.0/255.0, blue: 71.0/255.0, alpha: 1.0)
    public static var lightPurple = UIColor(red: 187.0/255.0, green: 105.0/355.0, blue: 255.0/255.0, alpha: 1.0)
    public static var veryLightPurple = UIColor(red: 240.0/255.0, green: 227.0/355.0, blue: 250.0/255.0, alpha: 1.0)
    public static var lightPurpWords = UIColor(red: 204.0/255.0, green: 204.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    public static var veryLightGrey = UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 1.0)
    public static var lightGrey = UIColor(red: 200.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, alpha: 1.0)
    public static var darkPink = UIColor(red: 234.0/255.0, green: 0.0/255.0, blue: 97.0/255.0, alpha: 1.0)
    public static var fadedDarkPink = UIColor(red: 234.0/255.0, green: 0.0/255.0, blue: 97.0/255.0, alpha: 0.5)
    public static var lightPink = UIColor(red: 255.0/255.0, green: 140.0/255.0, blue: 173.0/255.0, alpha: 1.0)
    public static var purple = UIColor(red: 199.0/255.0, green: 0.0/255.0, blue: 172.0/255.0, alpha: 1.0)
    
    //swapped
    public static var green = UIColor(red: 9.0/255.0, green: 196.0/255.0, blue: 122.0/255.0, alpha: 1.0)
    public static var neonGreen = UIColor(red: 52.0/255.0, green: 200.0/255.0, blue: 90.0/255.0, alpha: 1.0)
    
    
    public static var yellow = UIColor(red: 230.0/255.0, green: 225.0/255.0, blue: 37.0/255.0, alpha: 1.0)
    public static var blue = UIColor(red: 0.0/255.0, green: 160.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    public static var lightblue = UIColor(red: 86.0/255.0, green: 182.0/255.0, blue: 255.0/255.0, alpha: 1.0)
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
    
    public static var bigGreen = UIColor(red: 49.0/255.0, green: 204.0/255.0, blue: 90.0/255.0, alpha: 1.0)
    public static var mediumGreen = UIColor(red: 46.0/255.0, green: 159.0/255.0, blue: 78.0/255.0, alpha: 1.0)
    public static var smallGreen = UIColor(red: 52.0/255.0, green: 119.0/255.0, blue: 77.0/255.0, alpha: 1.0)
    public static var neutralGrey = UIColor(red: 65.0/255.0, green: 70.0/255.0, blue: 84.0/255.0, alpha: 1.0)
    public static var smallRed = UIColor(red: 140.0/255.0, green: 68.0/255.0, blue: 78.0/255.0, alpha: 1.0)
    public static var mediumRed = UIColor(red: 192.0/255.0, green: 64.0/255.0, blue: 69.0/255.0, alpha: 1.0)
    public static var bigRed = UIColor(red: 246.0/255.0, green: 53.0/255.0, blue: 56.0/255.0, alpha: 1.0)


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
