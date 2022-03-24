//
//  NewsSentiment.swift
//  stonks
//
//  Created by Samuel Hobel on 3/8/22.
//  Copyright © 2022 Samuel Hobel. All rights reserved.
//

import Foundation
import ObjectMapper

struct NewsSentiment:Mappable {
    var buzz:Double?//
    var bullishSentiment:Double? //
    var sectorAverageBullishSentiment:Double?//
    var score: Double?//
    var sectorAverageScore:Double?//
    var date:String?//
    
    init(){}
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        buzz <- map["buzz"]
        date <- map["creationDate"]
        bullishSentiment <- map["bullishSentiment"]
        sectorAverageBullishSentiment <- map["sectorAverageBullishSentiment"]
        score <- map["score"]
        sectorAverageScore <- map["sectorAverageScore"]
    }
}
