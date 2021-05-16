//
//  StocktwitsPost.swift
//  stonks
//
//  Created by Samuel Hobel on 10/25/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import Foundation
import ObjectMapper
struct StocktwitsSentiment: Mappable {
    
    public var sentiment:Double?// 0.20365833333333336,
    public var totalScores:Int?// 24,
    public var positive:Double?// 0.88,
    public var negative:Double?// 0.12
    
    init(){}
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        sentiment <- map["sentiment"]
        totalScores <- map["totalScores"]
        positive <- map["positive"]
        negative <- map["negative"]
    }
}
