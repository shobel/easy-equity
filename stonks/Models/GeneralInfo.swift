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
    public var companyName:String? //Apple Inc.
    public var exchange:String? //NASDAQ
    public var industry:String? //Telecomms
    public var website:String?
    public var description:String?
    public var CEO:String?
    public var securityName:String? //Apple Inc.
    public var issueType:String? //cs
    public var sector:String? //Electronic Technology
    public var tags:[String]?
    
    init(){}
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        symbol <- map["symbol"]
        companyName <- map["companyName"]
        description <- map["description"]
        exchange <- map["exchange"]
        industry <- map["industry"]
        website <- map["website"]
        CEO <- map["CEO"]
        securityName <- map["securityName"]
        issueType <- map["issueType"]
        sector <- map["sector"]
        tags <- map["tags"]
    }
 
}
