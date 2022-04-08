//
//  Tweet.swift
//  stonks
//
//  Created by Samuel Hobel on 4/3/22.
//  Copyright © 2022 Samuel Hobel. All rights reserved.
//

import Foundation
import ObjectMapper

struct Tweet:Mappable {
    public var text:String?
    public var cashtags:[String]?
    public var sentiment:Double?
    public var createdAt:String?
    
    init(){}
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        text <- map["text"]
        cashtags <- map["cashtags"]
        sentiment <- map["sentiment"]
        createdAt <- map["created_at"]
    }
}
