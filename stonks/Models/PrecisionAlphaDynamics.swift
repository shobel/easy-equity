//
//  PrecisionAlphaDynamics.swift
//  stonks
//
//  Created by Samuel Hobel on 3/21/22.
//  Copyright © 2022 Samuel Hobel. All rights reserved.
//

import Foundation
import ObjectMapper

struct PrecisionAlphaDynamics: Mappable,PremiumDataBase {
    
    var id:String?// date from firebase collection doc
    var key:String?// "BAC",
    var subkey:String?// "2020-10-02",
    var symbol:String?// "BAC",
    var companyName:String?// "Bank of America Corp.",
    var closeDate:String?// "2020-10-02",
    var probabilityUp:Double?// 0.5545,
    var probabilityDown:Double?// 0.4455,
    var marketEmotion:Double?// -379.8855,
    var marketPower:Double?// 52492.8458,
    var marketResistance:Double?// 2.7492,
    var marketNoise:Double?// 1.5152,
    var marketTemperature:Double?// 0.57612,
    var marketFreeEnergy:Double?// -223.9996,
    var date:Int?// 1601611200000,
    var updated:Int?// 1601697600000
    
    init(){}
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        key <- map["key"]
        subkey <- map["subkey"]
        symbol <- map["symbol"]
        companyName <- map["companyName"]
        closeDate <- map["closeDate"]
        probabilityUp <- map["probabilityUp"]
        probabilityDown <- map["probabilityDown"]
        marketEmotion <- map["marketEmotion"]
        marketPower <- map["marketPower"]
        marketResistance <- map["marketResistance"]
        marketNoise <- map["marketNoise"]
        marketTemperature <- map["marketTemperature"]
        marketFreeEnergy <- map["marketFreeEnergy"]
        date <- map["date"]
        updated <- map["updated"]
    }
}
