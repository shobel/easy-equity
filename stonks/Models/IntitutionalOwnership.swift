//
//  Estimates.swift
//  stonks
//
//  Created by Samuel Hobel on 9/2/19.
//  Copyright © 2019 Samuel Hobel. All rights reserved.
//

import Foundation
import ObjectMapper
struct InstitionalOwnership: Mappable {
    
    public var change:Int?
    public var shares:Int?
    
    init(){}
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        change <- map["change"]
        shares <- map["shares"]
    }

}
