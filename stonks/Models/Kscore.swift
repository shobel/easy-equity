//
//  Financials.swift
//  stonks
//
//  Created by Samuel Hobel on 9/2/19.
//  Copyright © 2019 Samuel Hobel. All rights reserved.
//

import Foundation
import ObjectMapper

struct Kscore: Mappable {
        
    //A score indicative of how well-managed a company is and whether its financial strength is solid. Factors include but are not limited to: working capital to long-term debt ratio, Greenblatt ROC, dividend payout, and operating profitability.
    var qualityScore:Int?// 8,
    
    //A score indicative of whether a stock is overpriced or underpriced. Factors include but are not limited to: earnings yield, price to book, enterprise value to EBITDA, and price to sales.
    var valueScore:Int? // 3,
    
    //A score indcative of a stock’s growth and growth factors. Factors include but are not limited to: ROA/ROE three year growth rate and sustainable earnings.
    var growthScore:Int? // 7
    
    //A score indicative of the stock’s momentum. Factors include but are not limited to: relative strength index, 52-week high/low, earnings momentum.
    var momentumScore:Int? // 6,
    
    //A predictive analytics equity rating score with possible values from 1 to 9. Taking into consideration over 200 factors and signals from fundamental to price/volume to alternative data, and using machine learning techniques and ranking algorithms, Kavout assigns an easy to understand and actionable 1-9 equity rating score.
    var kscore:Int? // 5,

    var updated:String? // 1609858771493,
    var id:String? // "2020-08-17",
    var subkey:String? // "2020-08-11",
    var symbol:String? // "A",
    var companyName:String? // "Agilent Technologies Inc.",
    var tradeDate:String? // "2020-08-05", Date on which the score calculation is done. Scores are calculated at least three hours prior to market open
    var key:String? // "A",
    
    init(){}
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        qualityScore <- map["qualityScore"]
        valueScore <- map["valueScore"]
        symbol <- map["symbol"]
        updated <- map["updated"]
        momentumScore <- map["momentumScore"]
        growthScore <- map["growthScore"]
        id <- map["id"]
        kscore <- map["kscore"]
        companyName <- map["companyName"]
        key <- map["key"]
        subkey <- map["subkey"]
        tradeDate <- map["tradeDate"]
    }
    
}
