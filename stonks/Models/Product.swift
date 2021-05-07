//
//  Product.swift
//  stonks
//
//  Created by Samuel Hobel on 4/15/21.
//  Copyright © 2021 Samuel Hobel. All rights reserved.
//

import Foundation
import ObjectMapper

struct Product: Mappable {
    
    public var id:String?
    public var credits:Int?
    public var usd:Double?
    
    init(){}
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        credits <- map["credits"]
        usd <- map["usd"]
    }

}
