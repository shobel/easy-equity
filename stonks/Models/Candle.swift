//
//  Candle.swift
//  stonks
//
//  Created by Samuel Hobel on 9/28/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftyJSON
struct Candle: Mappable {
    
    public var date:Date? //for sorting
    public var datetime:String?
    public var dateLabel:String?
    public var volume:Double?
    public var high:Double?
    public var low:Double?
    public var open:Double?
    public var close:Double?

    public var sma20:Double?
    public var sma50:Double?
    public var sma100:Double?
    public var sma200:Double?
    public var earnings:Bool?
    
    init(){}
    
    init(date:Date, datetime:String, volume:Double, high:Double, low:Double, open:Double, close:Double){
        self.date = date //for sorting
        self.datetime = datetime
        self.volume = volume
        self.high = high
        self.low = low
        self.open = open
        self.close = close
    }
    
    init(datetime:String, volume:Double, high:Double, low:Double, open:Double, close:Double){
        self.datetime = datetime
        self.volume = volume
        self.high = high
        self.low = low
        self.open = open
        self.close = close
    }
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        volume <- map["volume"]
        open <- map["open"]
        close <- map["close"]
        high <- map["high"]
        low <- map["low"]
        datetime <- map["label"] //varies
    }
    
    public static func createNonIntradayCandleFromJson(jsoncandle:JSON) -> Candle{
        var candle = Candle()
        candle.close = jsoncandle["close"].double ?? 0
        candle.open = jsoncandle["open"].double ?? 0
        candle.high = jsoncandle["high"].double ?? 0
        candle.low = jsoncandle["low"].double ?? 0
        candle.volume = jsoncandle["volume"].double ?? 0
        candle.datetime = jsoncandle["date"].string ?? ""
        candle.dateLabel = jsoncandle["date"].string ?? ""
        candle.earnings = jsoncandle["earnings"].bool ?? false
        if let sma20 = jsoncandle["sma20"].double {
            candle.sma20 = sma20
        }
        if let sma50 = jsoncandle["sma50"].double {
            candle.sma50 = sma50
        }
        if let sma100 = jsoncandle["sma100"].double {
            candle.sma100 = sma100
        }
        if let sma200 = jsoncandle["sma200"].double {
            candle.sma200 = sma200
        }
        return candle
    }
}
