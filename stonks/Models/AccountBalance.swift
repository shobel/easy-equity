//
//  AccountBalance.swift
//  stonks
//
//  Created by Samuel Hobel on 6/1/22.
//  Copyright © 2022 Samuel Hobel. All rights reserved.
//

import Foundation
import ObjectMapper

struct AccountBalance:Mappable {
    
    var available:Double? //32197.4426
    var current:Double? //101879.58669789
    var iso_currency_code:String? //"USD"
    var limit:Double? //null
    
    init(){}
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        available <- map["available"]
        current <- map["current"]
        iso_currency_code <- map["iso_currency_code"]
        limit <- map["limit"]
    }
}
