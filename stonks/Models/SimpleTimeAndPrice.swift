//
//  SimpleTimeAndPrice.swift
//  stonks
//
//  Created by Samuel Hobel on 5/15/21.
//  Copyright © 2021 Samuel Hobel. All rights reserved.
//

import Foundation
import ObjectMapper

struct SimpleTimeAndPrice: Mappable {
    
    public var priceTarget:Double?
    public var date:String?
    public var timestamp:Int?
    
    init(){}
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        priceTarget <- map["priceTarget"]
        timestamp <- map["timestamp"]
        date <- map["date"]
    }
    
}
