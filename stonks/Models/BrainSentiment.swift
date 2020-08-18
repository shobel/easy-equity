//
//  Financials.swift
//  stonks
//
//  Created by Samuel Hobel on 9/2/19.
//  Copyright © 2019 Samuel Hobel. All rights reserved.
//

import Foundation
import ObjectMapper

struct BrainSentiment: Mappable {
        
    var volumeSentiment:Int?
    var calculationDate:String?
    var symbol:String?
    var updated:Int? //timestamp
    var sentimentScore:Double? // 0.2653, (negative) -1 to 1 (positive)
    var compositeFigi:String? // "B0B6DG0V03C2" some sort of identifier
    var id:String? //same as calculation date
    var numberOfDaysIncluded:Int? //30
    var volume:Int? // 94 Number of news articles detected in the previous 30 days for the company.
    var companyName:String?
    var key:String? // "A",
    var subkey:String? // "2020-08-17"
    
    init(){}
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        volumeSentiment <- map["volumeSentiment"]
        calculationDate <- map["calculationDate"]
        symbol <- map["symbol"]
        updated <- map["updated"]
        sentimentScore <- map["sentimentScore"]
        compositeFigi <- map["compositeFigi"]
        id <- map["id"]
        numberOfDaysIncluded <- map["numberOfDaysIncluded"]
        volume <- map["volume"]
        companyName <- map["companyName"]
        key <- map["key"]
        subkey <- map["subkey"]
    }
    
}
