//
//  TacticalModel.swift
//  stonks
//
//  Created by Samuel Hobel on 4/12/22.
//  Copyright © 2022 Samuel Hobel. All rights reserved.
//

import Foundation
import ObjectMapper

struct TacticalModel: Mappable, PremiumDataBase {
        
    var reversalComponent:Int?//
    var factorMomentumComponent:Int?//
    var liquidityShockComponent:Int?//
    var seasonalityComponent:Int?//
    var tm1:Int?//
    var updated:Int?//1571832000000
    var id:String?//PREMIUM_EXTRACT_ALPHA_CAM",
    var key:String?// "AAPL",
    var subkey:String?// "2019-10-31",
    var date:Int?// 1571832000000
    
    init(){}
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        reversalComponent <- map["reversalComponent"]
        factorMomentumComponent <- map["factorMomentumComponent"]
        liquidityShockComponent <- map["liquidityShockComponent"]
        seasonalityComponent <- map["seasonalityComponent"]
        tm1 <- map["tm1"]
        updated <- map["updated"]
        id <- map["id"]
        key <- map["key"]
        subkey <- map["subkey"]
        date <- map["date"]
    }
}
