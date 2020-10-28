//
//  ScoreSettings.swift
//  stonks
//
//  Created by Samuel Hobel on 10/24/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import Foundation
import ObjectMapper
struct ScoreSettings: Mappable {
    
    public var disabled:[String]?
    public var weightings:[String:Double]?
    
    init(){}
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        disabled <- map["disabled"]
        weightings <- map["weightings"]
    }
}
