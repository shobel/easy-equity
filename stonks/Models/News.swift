//
//  News.swift
//  stonks
//
//  Created by Samuel Hobel on 9/2/19.
//  Copyright © 2019 Samuel Hobel. All rights reserved.
//

import Foundation
import ObjectMapper

struct News: Mappable {

    // 1 point - free
    
    public var datetime:Int? //1545215400000,
    public var headline:String? //"Voice Search Technology Creates A New Paradigm For Marketers",
    public var source:String? //"Benzinga",
    public var url:String? //"https://cloud.iexapis.com/stable/news/article/8348646549980454",
    public var summary:String? //"adsfadsfas"
    public var related:String? //"AAPL,AMZN,GOOG,GOOGL,MSFT",
    public var image:String? //"https://cloud.iexapis.com/stable/news/image/7594023985414148",
    public var lang:String? //"en",
    public var hasPaywall:Bool? //true
    
    init(){}
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        datetime <- map["datetime"]
        headline <- map["headline"]
        source <- map["source"]
        url <- map["url"]
        summary <- map["summary"]
        related <- map["related"]
        image <- map["image"]
        lang <- map["lang"]
        hasPaywall <- map["hasPaywall"]
    }
    
}
