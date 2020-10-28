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
    var open:Double? //154,
    var openTime:Int? //1506605400394,
    var close:Double? //153.28,
    var closeTime:Int? //1506605400394,
    var high:Double? //154.80,
    var low:Double? //153.25,
    var latestSource:String? //"Previous close",
    var latestVolume:Int? //20567140,
    var extendedChange:Double? //-1.68,
    var extendedPriceTime:Int? //1527082200361,
    var avgTotalVolume:Int? //29623234,
    var week52Low:Double? //93.63,
    var week52High:Double? //"week52High":233.47
    var peRatio:Double? //17.18,
    var latestPrice:Double? //224.29
    var latestTime:String? //"latestTime":"October 5, 2018",
    var latestUpdate:Int? // epoch time
    var previousClose:Double? //227.99
    var change:Double? //-3.7
    var changePercent:Double? //-0.01623
    var extendedPrice:Double? //"extendedPrice":224.54
    var extendedChangePercent:Double? //"extendedChangePercent":0.00111
    var lastTradeTime:Int? //1567799999401,
    
    var isUSMarketOpen:Bool = false
    var simplifiedChart:[DatedValue] = []
        
    public func getYrHighChangePercent() -> Double {
        return ((self.latestPrice! - self.week52High!) / (self.week52High!))*100.0
    }
    
    init() {}
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        symbol <- map["symbol"]
        open <- map["open"]
        openTime <- map["openTime"]
        close <- map["close"]
        closeTime <- map["closeTime"]
        high <- map["high"]
        low <- map["low"]
        latestSource <- map["latestSource"]
        latestVolume <- map["latestVolume"]
        extendedChange <- map["extendedChange"]
        extendedPriceTime <- map["extendedPriceTime"]
        extendedPrice <- map["extendedPrice"]
        extendedChangePercent <- map["extendedChangePercent"]
        avgTotalVolume <- map["avgTotalVolume"]
        week52Low <- map["week52Low"]
        week52High <- map["week52High"]
        peRatio <- map["peRatio"]
        latestPrice <- map["latestPrice"]
        latestTime <- map["latestTime"]
        latestUpdate <- map["latestUpdate"]
        previousClose <- map["previousClose"]
        change <- map["change"]
        changePercent <- map["changePercent"]
        lastTradeTime <- map["lastTradeTime"]
        isUSMarketOpen <- map["isUSMarketOpen"]
    }
}

