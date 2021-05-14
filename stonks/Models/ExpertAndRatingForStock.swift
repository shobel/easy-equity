//
//  ExpertRating.swift
//  stonks
//
//  Created by Samuel Hobel on 5/13/21.
//  Copyright © 2021 Samuel Hobel. All rights reserved.
//

import Foundation
import ObjectMapper

struct ExpertAndRatingForStock: Mappable {
    
    public var avgReturn:Double?// 0.353
    public var firm:String?// "Wells Fargo"
    public var name:String?// "Brian Fitzgerald"
    public var numRatings:Int?// 359
    public var rank:Int?// 26
    public var sector:String?// "technology"
    public var successRate:Double?// 0.7270194986072424
    public var type:String?// "analyst"
    public var typeRank:Int?// 15
    public var stars:Double?//3.5
    public var stockRating:StockRating?
    
    init(){}
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        avgReturn <- map["avgReturn"]
        firm <- map["firm"]
        name <- map["name"]
        numRatings <- map["numRatings"]
        rank <- map["rank"]
        sector <- map["sector"]
        successRate <- map["successRate"]
        type <- map["type"]
        typeRank <- map["typeRank"]
        stars <- map["stars"]
        stockRating <- map["stockRating"]
    }
}

