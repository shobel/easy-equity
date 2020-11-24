//
//  FearGreedIndicator.swift
//  stonks
//
//  Created by Samuel Hobel on 11/23/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import Foundation
import ObjectMapper

struct FearGreedIndicator: Mappable {
    
    public var name:String?
    public var indicatorValue:String?
    public var indicatorDescription:String?
    
    init(){}
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        name <- map["name"]
        indicatorValue <- map["value"]
        indicatorDescription <- map["description"]
    }
}
