//
//  EconomyWeekly.swift
//  stonks
//
//  Created by Samuel Hobel on 11/24/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import Foundation
import ObjectMapper
struct EconomyMonthly: Mappable {
    
    private var date:String? // "2020-11-01",
    private var recessionProbability:Int? // 101,
    private var consumerPriceIndex:Double?// 265.911,
    private var unemploymentPercent:Double? // 8.1,
    private var fedFundsRate:Double? // 0.09,
    private var industrialProductionIndex:Double? //105.3354
    
    init(){}
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        date <- map["id"]
        recessionProbability <- map["consumerPriceIndex"]
        consumerPriceIndex <- map["consumerPriceIndex"]
        unemploymentPercent <- map["unemploymentPercent"]
        fedFundsRate <- map["fedFundsRate"]
        industrialProductionIndex <- map["industrialProductionIndex"]
    }
}
