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
    private var retailMoneyFunds:Int? // 1131,
    private var institutionalMoneyFunds:Double? //2916.1
    
    public static var fields:[String] = ["initialClaims", "retailMoneyFunds", "institutionalMoneyFunds"]
    public static var names:[String] = ["Initial Jobless Claims", "Retail Money Funds", "Institutional Money Funds"]
    
    init(){}
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        initialClaims <- map["initialClaims"]
        date <- map["id"]
        retailMoneyFunds <- map["retailMoneyFunds"]
        institutionalMoneyFunds <- map["institutionalMoneyFunds"]
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
                    case "retailMoneyFunds":
                        if weekly.retailMoneyFunds != nil {
                            foundValue = true
                            curVal = Double(weekly.retailMoneyFunds ?? 0)
                            em.values.append(curVal)
                        }
                        break
                    case "institutionalMoneyFunds":
                        if weekly.institutionalMoneyFunds != nil {
                            foundValue = true
                            curVal = Double(weekly.institutionalMoneyFunds ?? 0)
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
