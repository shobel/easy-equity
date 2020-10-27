//
//  StocktwitsPost.swift
//  stonks
//
//  Created by Samuel Hobel on 10/25/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import Foundation
import ObjectMapper
struct StocktwitsPost: Mappable {
    
    public var body:String?
    public var timestamp:Int?
    public var username:String?
    public var sentiment:String?
    public var symbols:[String]?
    public var createdAt:String?
    
    init(){}
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        body <- map["body"]
        timestamp <- map["timestamp"]
        username <- map["username"]
        sentiment <- map["sentiment"]
        symbols <- map["symbols"]
        createdAt <- map["createdAt"]
    }
}
