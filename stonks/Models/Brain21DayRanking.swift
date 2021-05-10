//
//  Brain21DayRanking.swift
//  stonks
//
//  Created by Samuel Hobel on 5/8/21.
//  Copyright © 2021 Samuel Hobel. All rights reserved.
//

import Foundation
import ObjectMapper

struct Brain21DayRanking: Mappable {
    
    public var id:String?// "PREMIUM_BRAIN_RANKING_21_DAYS",
    public var source:String?// "Brain Company",
    public var key:String? //"BAC",
    public var subkey:String?// "2020-01-13",
    public var calculationDate:String?// "2020-01-13",
    public var companyName:String?// "Bank of America Corp.",
    public var compositeFigi:String?// "BBG000BCTLF6",
    public var symbol:String?// "BAC",
    public var mlAlpha:Double?// -0.034,
    public var daysForecast:Int?// 21
    
    init(){}
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        source <- map["source"]
        key <- map["key"]
        subkey <- map["subkey"]
        calculationDate <- map["calculationDate"]
        companyName <- map["companyName"]
        compositeFigi <- map["compositeFigi"]
        symbol <- map["symbol"]
        mlAlpha <- map["mlAlpha"]
        daysForecast <- map["daysForecast"]
    }

}
