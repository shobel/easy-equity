//
//  DateAndBalance.swift
//  stonks
//
//  Created by Samuel Hobel on 6/2/22.
//  Copyright © 2022 Samuel Hobel. All rights reserved.
//

import Foundation
import ObjectMapper

struct DateAndBalance: Mappable {
    
    public var balance:Double?
    public var timestamp:String?
    
    init(){}
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        timestamp <- map["timestamp"]
        balance <- map["balance"]
    }
    
}
