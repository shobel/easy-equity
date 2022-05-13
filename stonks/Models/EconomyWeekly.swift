//
//  EconomyWeekly.swift
//  stonks
//
//  Created by Samuel Hobel on 11/24/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import Foundation
import ObjectMapper
struct EconomyWeekly: Mappable {
    
    private var initialClaims:Int? // 770244,
    private var date:String? // "2020-11-15",
    
    public static var fields:[String] = ["initialClaims"]
    public static var names:[String] = ["Initial Jobless Claims"]
    
    init(){}
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        initialClaims <- map["initialClaims"]
        date <- map["id"]
    }
    
    public static func getValueArrayFromEconomyWeeklies(weeklies:[EconomyWeekly]) -> [EconomyMetric] {
        var retArray:[EconomyMetric] = []
        for i in 0..<fields.count {
            var em:EconomyMetric = EconomyMetric()
            let field = fields[i]
            let name = names[i]
            em.name = name
            var foundFirstValue = false
            for j in 0..<weeklies.count {
                let weekly = weeklies[j]
                var foundValue = false
                var curVal = 0.0
                switch field {
                    case "initialClaims":
                        if weekly.initialClaims != nil {
                            foundValue = true
                            curVal = Double(weekly.initialClaims ?? 0)
                            em.values.append(curVal)
                        }
                        break
                    default:
                        break
                }
                if !foundFirstValue && foundValue {
                    foundFirstValue = true
                    em.latestValue = curVal
                }
            }
            em.values.reverse()
            retArray.append(em)
        }
        return retArray
    }
}
