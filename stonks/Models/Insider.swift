//
//  Estimates.swift
//  stonks
//
//  Created by Samuel Hobel on 9/2/19.
//  Copyright © 2019 Samuel Hobel. All rights reserved.
//

import Foundation
import ObjectMapper
struct Insider: Mappable {
    //very expensive 5,000
    
    public var netTransacted:Int?
    public var fullName:String?
    public var totalSold:Int?
    public var reportedTitle:String?
    public var totalBought:Int?
    
    init(){}
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        netTransacted <- map["netTransacted"]
        fullName <- map["fullName"]
        totalSold <- map["totalSold"]
        reportedTitle <- map["reportedTitle"]
        totalBought <- map["totalBought"]
    }

}
