//
//  Scores.swift
//  stonks
//
//  Created by Samuel Hobel on 10/18/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import Foundation
import ObjectMapper
struct Scores: Mappable {
    
    public var futureGrowth:[String:Double]?
    public var financialHealth:[String:Double]?
    public var pastPerformance:[String:Double]?
    public var valuation:[String:Double]?
    public var technical:[String:Double]?
    public var overallScore:Double?
    public var percentile:Double?
    
    init(){}
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        futureGrowth <- map["categories.future"]
        financialHealth <- map["categories.health"]
        pastPerformance <- map["categories.past"]
        valuation <- map["categories.valuation"]
        technical <- map["categories.technical"]
        overallScore <- map["overallScore"]
        percentile <- map["percentile"]
    }

}
