//
//  Quote.swift
//  stonks
//
//  Created by Samuel Hobel on 10/8/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import Foundation
import ObjectMapper
struct Quote: Mappable {
    
    var symbol:String? //AAPL
    var name:String? //company name
    var latestPrice:Double? //224.29
    var changePercent:Double? //-0.01623
    var change:Double? //-3.7
    var high:Double? //154.80,
    var low:Double? //153.25,
    var week52Low:Double? //93.63,
    var week52High:Double? //"week52High":233.47
    var marketCap:Double? //marketcap
    var avgTotalVolume:Int? //29623234,
    var latestVolume:Int? //20567140,
    var open:Double? //154,
    var close:Double? //153.28,
    var peRatio:Double? //17.18,
    var eps:Double?
    var latestUpdate:Int? // epoch time
    var previousClose:Double? //227.99
    var earningsAnnouncement:String?
    var daysToEarnings:Int?
    
    //extended - these fields will be null during market hours
    var extendedPrice:Double?
    var extendedPriceTime:Double?
    var extendedChangePercent:Double?
    
    var simplifiedChart:[DatedValue] = []
    
    // have this data available but no need
    //var priceAvg50:Double?
    //var priceAvg200:Double?
    //var exchange:String?
    //var sharesOutstanding:Int?
        
    public func getYrHighChangePercent() -> Double {
        return ((self.latestPrice! - self.week52High!) / (self.week52High!))*100.0
    }
    
    init() {}
    
    init?(map: Map) {}
    
    //maps FMPQuote to the fields I use throughout the frontend
    mutating func mapping(map: Map) {
        symbol <- map["symbol"]
        name <- map["name"]
        latestPrice <- map["price"]
        changePercent <- map["changesPercentage"]
        change <- map["change"]
        high <- map["dayHigh"]
        low <- map["dayLow"]
        week52Low <- map["yearLow"]
        week52High <- map["yearHigh"]
        marketCap <- map["marketCap"]
        avgTotalVolume <- map["avgVolume"]
        latestVolume <- map["volume"]
        open <- map["open"]
        close <- map["close"]
        peRatio <- map["pe"]
        eps <- map["eps"]
        latestUpdate <- map["timestamp"]
        previousClose <- map["previousClose"]
        earningsAnnouncement <- map["earningsAnnouncement"]
        daysToEarnings <- map["daysToEarnings"]

        extendedPrice <- map["extendedPrice"]
        extendedPriceTime <- map["extendedPriceTime"]
        extendedChangePercent <- map["extendedChangePercent"]
    }
}

