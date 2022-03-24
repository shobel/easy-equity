//
//  GeneralInfo.swift
//  stonks
//
//  Created by Samuel Hobel on 8/25/19.
//  Copyright © 2019 Samuel Hobel. All rights reserved.
//

import Foundation
import ObjectMapper

struct GeneralInfo: Mappable {
    public var symbol:String? //AAPL
    public var isCompany:Bool? //is either company or etf
    public var logo:String?
    public var companyName:String? //Apple Inc.
    public var exchange:String? //NASDAQ
    public var industry:String? //Telecomms
    public var city:String?
    public var state:String?
    public var country:String?
    public var website:String?
    public var description:String?
    public var ceo:String?
//    public var issueType:String? //cs
    public var sector:String? //Electronic Technology
    public var employees:Int?
//    public var tags:[String]?
    public var peers:[String]?
    
    var currency:String?// "USD",
    var exchangeShortName:String?// "AMEX",
    var address:String?
    var zip:String?
    var ipoDate:String?// "2010-09-07",
    var isEtf:Bool?// true,
    var isActivelyTrading:Bool?
    var isAdr:Bool?
    var isFund:Bool?
    
    //
    var price:Double?
    var beta:Double?
    var volAvg:Double?
    var marketCap:Int?
    var lastDiv:Double?
    var range:String?// "354.14-441.26",
    var changes: Double? //10.2 %change of day
    var dcfDiff:Double?//null,
    var dcf:Double?// 0.0,
    
    var float:Int?
    var sharesOutstanding:Int?
    var freeFloat:Double?
    
    init(){}
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        symbol <- map["symbol"]
        logo <- map["logo"]
        isCompany <- map["isCompany"]
        companyName <- map["companyName"]
        description <- map["description"]
        exchange <- map["exchange"]
        industry <- map["industry"]
        website <- map["website"]
        employees <- map["employees"]
        ceo <- map["ceo"]
        city <- map["city"]
        state <- map["state"]
        country <- map["country"]
        sector <- map["sector"]
        peers <- map["peers"]
        currency <- map["currency"]
        exchangeShortName <- map["exchangeShortName"]
        address <- map["address"]
        zip <- map["zip"]
        ipoDate <- map["ipoDate"]
        isEtf <- map["isEtf"]
        isActivelyTrading <- map["isActivelyTrading"]
        isAdr <- map["isAdr"]
        isFund <- map["isFund"]
        
        beta <- map["beta"]
        volAvg <- map["volAvg"]
        marketCap <- map["mktCap"]
        lastDiv <- map["lastDiv"]
        range <- map["range"]
        changes <- map["changes"]
        dcfDiff <- map["dcfDiff"]
        dcf <- map["dcf"]
        
        float <- map["float"]
        sharesOutstanding <- map["sharesOutstanding"]
        freeFloat <- map["freeFloat"]

    }
 
}
