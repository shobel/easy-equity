//
//  Recommendations.swift
//  stonks
//
//  Created by Samuel Hobel on 9/2/19.
//  Copyright © 2019 Samuel Hobel. All rights reserved.
//

import Foundation
import ObjectMapper

struct Recommendations: Mappable {
    //1,000 points
    
    public var consensusEndDate:Int? //1542240000000,
    public var consensusStartDate:Int? //1541462400000,
    public var corporateActionsAppliedDate:Int? //1055721600000,
    public var ratingBuy:Int? //8,
    public var ratingHold:Int? //1,
    public var ratingNone:Int? //2,
    public var ratingOverweight:Int? //2,
    public var ratingScaleMark:Double? //1.042857,
    public var ratingSell:Int? //1,
    public var ratingUnderweight:Int? //1
    
    init(){}
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        consensusEndDate <- map["consensusEndDate"]
        consensusStartDate <- map["consensusStartDate"]
        corporateActionsAppliedDate <- map["corporateActionsAppliedDate"]
        ratingBuy <- map["ratingBuy"]
        ratingHold <- map["ratingHold"]
        ratingNone <- map["ratingNone"]
        ratingOverweight <- map["ratingOverweight"]
        ratingScaleMark <- map["ratingScaleMark"]
        ratingSell <- map["ratingSell"]
        ratingUnderweight <- map["ratingUnderweight"]
    }
}
