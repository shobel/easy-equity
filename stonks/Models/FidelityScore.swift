//
//  FidelityScore.swift
//  stonks
//
//  Created by Samuel Hobel on 2/12/22.
//  Copyright © 2022 Samuel Hobel. All rights reserved.
//

import Foundation
import ObjectMapper

struct FidelityScore: Mappable {
    var symbol: String?
    var score:String?
    var dayChange:Double?
    
    init(){}
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        score <- map["score"]
        dayChange <- map["dayChange"]
        symbol <- map["symbol"]
    }
    
}
