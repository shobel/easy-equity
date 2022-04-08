//
//  KeyStats.swift
//  stonks
//
//  Created by Samuel Hobel on 8/25/19.
//  Copyright © 2019 Samuel Hobel. All rights reserved.
//

import Foundation
import ObjectMapper

struct BalanceSheet: Mappable {
    var cashAndCashEquivalents:Int?
    var fiscalDate:String?
    var netDebt:Int?
    var period:String?
    var reportDate:String?
    var totalAssets:Int?
    var totalDebt:Int?
    var totalLiabilities:Int?
    var totalStockholdersEquity:Int?
    
    init(){}
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        cashAndCashEquivalents <- map["cashAndCashEquivalents"]
        fiscalDate <- map["fiscalDate"]
        netDebt <- map["netDebt"]
        period <- map["period"]
        reportDate <- map["reportDate"]
        totalAssets <- map["totalAssets"]
        totalDebt <- map["totalDebt"]
        totalLiabilities <- map["totalLiabilities"]
        totalStockholdersEquity <- map["totalStockholdersEquity"]
    }
    
}
