//
//  PriceTarget.swift
//  stonks
//
//  Created by Samuel Hobel on 9/2/19.
//  Copyright © 2019 Samuel Hobel. All rights reserved.
//

import Foundation
import ObjectMapper

struct PriceTargetTopAnalysts: Mappable {
    
    public var symbol:String? //"AAPL",
    public var companyName:String? //Apple, Inc.
    public var avgAnalystRank:Double? //18.2,
    public var avgAnalystReturn:Double? //0.294 percent as decimal
    public var avgAnalystSuccessRate:Double? //0.75, percent as decimal
    public var avgPriceTarget:Double? //140,
    public var highPriceTarget:Double?
    public var lowPriceTarget:Double?
    public var numAnalysts:Int? //34
    public var numRatings:Int? //25
    public var upsidePercent:Double? //-16.73 actual percent
    
    init(){}
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        symbol <- map["symbol"]
        companyName <- map["companyName"]
        avgAnalystRank <- map["avgAnalystRank"]
        avgAnalystReturn <- map["avgAnalystReturn"]
        avgAnalystSuccessRate <- map["avgAnalystSuccessRate"]
        avgPriceTarget <- map["avgPriceTarget"]
        highPriceTarget <- map["highPriceTarget"]
        lowPriceTarget <- map["lowPriceTarget"]
        numAnalysts <- map["numAnalysts"]
        numRatings <- map["numRatings"]
        upsidePercent <- map["upsidePercent"]
    }
}
