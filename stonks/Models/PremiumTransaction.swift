//
//  Receipt.swift
//  stonks
//
//  Created by Samuel Hobel on 11/29/21.
//  Copyright © 2021 Samuel Hobel. All rights reserved.
//

import Foundation
import ObjectMapper

struct PremiumTransaction: Mappable {
    var credits: Int?
    var packageid:String?
    var symbol:String?
    var userid:String?
    var timestamp:Int?
    
    init(){}
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        credits <- map["credits"]
        packageid <- map["packageid"]
        symbol <- map["symbol"]
        userid <- map["userid"]
        timestamp <- map["timestamp"]
    }
    
}
