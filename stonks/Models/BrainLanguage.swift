//
//  Brain21DayRanking.swift
//  stonks
//
//  Created by Samuel Hobel on 5/8/21.
//  Copyright © 2021 Samuel Hobel. All rights reserved.
//

import Foundation
import ObjectMapper

struct BrainLanguage: Mappable {
    
    public var id:String?// "PREMIUM_BRAIN_RANKING_21_DAYS",
    public var source:String?// "Brain Company",
    public var key:String? //"BAC",
    public var subkey:String?// "2020-01-13",
    public var calculationDate:String?// "2020-01-13",
    public var companyName:String?// "Bank of America Corp.",
    public var compositeFigi:String?// "BBG000BCTLF6",
    public var symbol:String?// "BAC",
    public var lastReportCategory:String?// "10K",
    public var lastReportDate:String?// "2019-12-31",
    public var sentiment:Double?// 0.2755,
    public var scoreUncertainty:Double?// 0.2372,
    public var scoreLitigious:Double?// 0.1595,
    public var scoreConstraining:Double?// 0.122,
    public var scoreInteresting:Double?// 0.0754
    
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
        lastReportCategory <- map["lastReportCategory"]
        lastReportDate <- map["lastReportDate"]
        sentiment <- map["sentiment"]
        scoreUncertainty <- map["scoreUncertainty"]
        scoreLitigious <- map["scoreLitigious"]
        scoreConstraining <- map["scoreConstraining"]
        scoreInteresting <- map["scoreInteresting"]
    }

}
