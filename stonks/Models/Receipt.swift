//
//  Receipt.swift
//  stonks
//
//  Created by Samuel Hobel on 11/29/21.
//  Copyright © 2021 Samuel Hobel. All rights reserved.
//

import Foundation
import ObjectMapper

struct Receipt: Mappable {
    var product: Product? 
    var status:String? //complete
    var transactionid:String? //"1000000807946009"
    var userid:String? //dafdsfadsfads
    var timestamp:Int?
    
    init(){}
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        product <- map["product"]
        status <- map["status"]
        transactionid <- map["transactionid"]
        userid <- map["userid"]
        timestamp <- map["timestamp"]
    }
    
}
