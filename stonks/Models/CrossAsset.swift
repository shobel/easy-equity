//
//  CrossAsset.swift
//  stonks
//
//  Created by Samuel Hobel on 4/12/22.
//  Copyright © 2022 Samuel Hobel. All rights reserved.
//

import Foundation
import ObjectMapper

struct CrossAsset: Mappable, PremiumDataBase {
        
    var spreadComponent:Int?//
    var skewComponent:Int?//
    var volumeComponent:Int?//
    var cam1:Int?//
    var cam1Slow:Int?//
    var updated:Int?//1571832000000
    var id:String?//PREMIUM_EXTRACT_ALPHA_CAM",
    var key:String?// "AAPL",
    var subkey:String?// "2019-10-31",
    var date:Int?// 1571832000000
    
    init(){}
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        spreadComponent <- map["spreadComponent"]
        skewComponent <- map["skewComponent"]
        volumeComponent <- map["volumeComponent"]
        cam1 <- map["cam1"]
        cam1Slow <- map["cam1Slow"]
        updated <- map["updated"]
        id <- map["id"]
        key <- map["key"]
        subkey <- map["subkey"]
        date <- map["date"]
    }
}
