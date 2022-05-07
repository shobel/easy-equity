//
//  PremiumPackage.swift
//  stonks
//
//  Created by Samuel Hobel on 5/6/21.
//  Copyright © 2021 Samuel Hobel. All rights reserved.
//

import Foundation
import ObjectMapper

struct PremiumPackage: Mappable {
    
    public var id:String?
    public var name:String?
    public var credits:Int?
    public var weight:Int?
    public var enabled:Bool?
    
    init(){}
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        credits <- map["credits"]
        weight <- map["weight"]
        name <- map["name"]
        enabled <- map["enabled"]
    }

}
