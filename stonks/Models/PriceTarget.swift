//
//  PriceTarget.swift
//  stonks
//
//  Created by Samuel Hobel on 9/2/19.
//  Copyright © 2019 Samuel Hobel. All rights reserved.
//

import Foundation
import ObjectMapper

struct PriceTarget: Mappable {
    
    //500 points
    
    public var symbol:String? //"AAPL",
    public var updatedDate:String? //"2019-01-30",
    public var priceTargetAverage:Double? //178.59,
    public var priceTargetHigh:Int? //245,
    public var priceTargetLow:Int? //140,
    public var numberOfAnalysts:Int? //34
    
    init(){}
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        symbol <- map["symbol"]
        updatedDate <- map["updatedDate"]
        priceTargetAverage <- map["priceTargetAverage"]
        priceTargetHigh <- map["priceTargetHigh"]
        priceTargetLow <- map["priceTargetLow"]
        numberOfAnalysts <- map["numberOfAnalysts"]
    }
}
