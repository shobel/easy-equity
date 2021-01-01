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
            for j in 0..<weeklies.count {
                let weekly = weeklies[j]
                var latestValue = 0.0
                switch field {
                    case "initialClaims":
                        latestValue = Double(weekly.initialClaims ?? 0)
                        em.values.append(Double(weekly.initialClaims ?? 0))
                        break
                    case "retailMoneyFunds":
                        latestValue = Double(weekly.retailMoneyFunds ?? 0)
                        em.values.append(Double(weekly.retailMoneyFunds ?? 0))
                        break
                    case "institutionalMoneyFunds":
                        latestValue = Double(weekly.institutionalMoneyFunds ?? 0)
                        em.values.append(Double(weekly.institutionalMoneyFunds ?? 0))
                        break
                    default:
                        break
                }
                if j == 0 {
                    em.latestValue = latestValue
                }
            }
            em.values.reverse()
            retArray.append(em)
        }
        return retArray
    }
}
