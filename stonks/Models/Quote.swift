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
    var iexRealtimePrice:Double? //158.71,
    var iexRealtimeSize:Int? //100,
    var iexLastUpdated:Int? //1505851198059,
    var delayedPrice:Double? //158.71,
    var delayedPriceTime:Int? //1505854782437,
    var extendedChange:Double? //-1.68,
    var extendedPriceTime:Int? //1527082200361,
    var iexMarketPercent:Double? //0.00948,
    var iexVolume:Int? //82451,
    var avgTotalVolume:Int? //29623234,
    var iexBidPrice:Double? //153.01,
    var iexBidSize:Int? //100,
    var iexAskPrice:Double? //158.66,
    var iexAskSize:Int? //100,
    var week52Low:Double? //93.63,
    var week52High:Double? //"week52High":233.47
    var peRatio:Double? //17.18,
    var latestPrice:Double? //224.29
    var latestTime:String? //"latestTime":"October 5, 2018",
    var latestUpdate:String? // epoch time
    var previousClose:Double? //227.99
    var change:Double? //-3.7
    var changePercent:Double? //-0.01623
    var extendedPrice:Double? //"extendedPrice":224.54
    var extendedChangePercent:Double? //"extendedChangePercent":0.00111
    var marketCap:Double? //"marketCap":1083304102540
    var ytdChange:Double? //"ytdChange":0.3007662925165673
    var lastTradeTime:Int? //1567799999401,
    var isUSMarketOpen:Bool? //false
    
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
        iexRealtimePrice <- map["iexRealtimePrice"]
        iexRealtimeSize <- map["iexRealtimeSize"]
        iexLastUpdated <- map["iexLastUpdated"]
        delayedPrice <- map["delayedPrice"]
        delayedPriceTime <- map["delayedPriceTime"]
        extendedChange <- map["extendedChange"]
        extendedPriceTime <- map["extendedPriceTime"]
        iexMarketPercent <- map["iexMarketPercent"]
        iexVolume <- map["iexVolume"]
        avgTotalVolume <- map["avgTotalVolume"]
        iexBidPrice <- map["iexBidPrice"]
        iexBidSize <- map["iexBidSize"]
        iexAskPrice <- map["iexAskPrice"]
        iexAskSize <- map["iexAskSize"]
        week52Low <- map["week52Low"]
        week52High <- map["week52High"]
        peRatio <- map["peRatio"]
        latestPrice <- map["latestPrice"]
        latestTime <- map["latestTime"]
        latestUpdate <- map["latestUpdate"]
        previousClose <- map["previousClose"]
        change <- map["change"]
        changePercent <- map["changePercent"]
        extendedPrice <- map["extendedPrice"]
        extendedChangePercent <- map["extendedChangePercent"]
        marketCap <- map["marketCap"]
        ytdChange <- map["ytdChange"]
        lastTradeTime <- map["lastTradeTime"]
        isUSMarketOpen <- map["isUSMarketOpen"]
    }
}

