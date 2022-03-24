//
//  SocialSentimentFMP.swift
//  stonks
//
//  Created by Samuel Hobel on 3/8/22.
//  Copyright © 2022 Samuel Hobel. All rights reserved.
//

import Foundation
import ObjectMapper

struct SocialSentimentFMP: Mappable {
    var date: String? //"2022-03-07 13:00:00",
    var symbol:String? // "AAPL",
    var stocktwitsPosts:Int? // 17,
    var twitterPosts:Int?// 124,
    var stocktwitsComments:Int?// 8,
    var twitterComments:Int?// 227,
    var stocktwitsLikes:Int?// 11,
    var twitterLikes:Int?// 847,
    var stocktwitsImpressions:Int?// 201080,
    var twitterImpressions:Int?// 1328233,
    var stocktwitsSentiment:Double?// 0.5032,
    var twitterSentiment:Double?// 0.5768
    
    init(){}
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        date <- map["date"]
        symbol <- map["symbol"]
        stocktwitsPosts <- map["stocktwitsPosts"]
        twitterPosts <- map["twitterPosts"]
        stocktwitsComments <- map["stocktwitsComments"]
        twitterComments <- map["twitterComments"]
        stocktwitsLikes <- map["stocktwitsLikes"]
        twitterLikes <- map["twitterLikes"]
        stocktwitsImpressions <- map["stocktwitsImpressions"]
        twitterImpressions <- map["twitterImpressions"]
        stocktwitsSentiment <- map["stocktwitsSentiment"]
        twitterSentiment <- map["twitterSentiment"]
    }
}
