//
//  SocialSentimentFMP.swift
//  stonks
//
//  Created by Samuel Hobel on 3/8/22.
//  Copyright © 2022 Samuel Hobel. All rights reserved.
//

import Foundation
import ObjectMapper

struct SocialSentimentChangeFMP: Mappable {
    
    var symbol:String?
    var name:String?
    var rank:Int?
    var sentiment:Double?
    var sentimentChange:Double?
    
    init(){}
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        symbol <- map["symbol"]
        name <- map["name"]
        rank <- map["rank"]
        sentiment <- map["sentiment"]
        sentimentChange <- map["sentimentChange"]
    }
}
