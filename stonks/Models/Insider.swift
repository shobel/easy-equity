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
    public var days:Int?
    
    init(){}
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        netTransacted <- map["netTransacted"]
        days <- map["days"]
    }

}
