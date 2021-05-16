//
//  StockRating.swift
//  stonks
//
//  Created by Samuel Hobel on 5/13/21.
//  Copyright © 2021 Samuel Hobel. All rights reserved.
//

import Foundation
import ObjectMapper

struct StockRating: Mappable {
    
    public var averageReturn:Double?// 0.32586666666666664
    public var companyName:String?// "Facebook"
    public var date:String?// "2021-04-29T00:00:00"
    public var timestamp:Int?//
    public var numRatings:Int?// 15
    public var position:String?// "Buy"
    public var priceTarget:Double?// 415
    public var successRate:Double?// 0.9333333333333333
    public var symbol:String?// "FB"
    
    init(){}
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        averageReturn <- map["averageReturn"]
        companyName <- map["companyName"]
        date <- map["date"]
        timestamp <- map["timestamp"]
        numRatings <- map["numRatings"]
        position <- map["position"]
        priceTarget <- map["priceTarget"]
        successRate <- map["successRate"]
        symbol <- map["symbol"]
    }

}
