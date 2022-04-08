//
//  cashtag.swift
//  stonks
//
//  Created by Samuel Hobel on 4/3/22.
//  Copyright © 2022 Samuel Hobel. All rights reserved.
//

import Foundation
import ObjectMapper

struct Cashtag: Mappable {
    
    public var symbol:String?
    public var overallSentiment:Double?
    public var count:Int?
    public var sentiments:[Double]?
    
    init(){}
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        symbol <- map["symbol"]
        count <- map["count"]
        overallSentiment <- map["overallSentiment"]
        sentiments <- map["sentiments"]
    }
    
}
