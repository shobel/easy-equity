//
//  Candle.swift
//  stonks
//
//  Created by Samuel Hobel on 9/28/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import Foundation
import ObjectMapper
struct Candle: Mappable {
    
    public var date:Date? //for sorting
    public var datetime:String?
    public var volume:Double?
    public var high:Double?
    public var low:Double?
    public var open:Double?
    public var close:Double?

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
}
