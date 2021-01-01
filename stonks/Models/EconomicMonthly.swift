//
//  EconomyWeekly.swift
//  stonks
//
//  Created by Samuel Hobel on 11/24/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import Foundation
import ObjectMapper
struct EconomyMonthly: Mappable {
    
    private var date:String? // "2020-11-01",
    private var recessionProbability:Int? // 101,
    private var consumerPriceIndex:Double?// 265.911,
    private var unemploymentPercent:Double? // 8.1,
    private var fedFundsRate:Double? // 0.09,
    private var industrialProductionIndex:Double? //105.3354
    
    public static var fields:[String] = ["recessionProbability", "consumerPriceIndex", "unemploymentPercent", "fedFundsRate", "industrialProductionIndex"]
    public static var names:[String] = ["Recession Probability", "Consumer Price Index", "Unemployment Percent", "Fed Funds Rate", "Industrial Production Index"]
    
    init(){}
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        date <- map["id"]
        recessionProbability <- map["recessionProbability"]
        consumerPriceIndex <- map["consumerPriceIndex"]
        unemploymentPercent <- map["unemploymentPercent"]
        fedFundsRate <- map["fedFundsRate"]
        industrialProductionIndex <- map["industrialProductionIndex"]
    }
    
    public static func getValueArrayFromEconomyMonthlies(monthlies:[EconomyMonthly]) -> [EconomyMetric] {
        var retArray:[EconomyMetric] = []
        for i in 0..<fields.count {
            var em:EconomyMetric = EconomyMetric()
            let field = fields[i]
            let name = names[i]
            em.name = name
            for j in 0..<monthlies.count {
                let monthly = monthlies[j]
                var latestValue = 0.0
                switch field {
                    case "recessionProbability":
                        latestValue = Double(monthly.recessionProbability ?? 0)
                        em.values.append(Double(monthly.recessionProbability ?? 0))
                        break
                    case "consumerPriceIndex":
                        latestValue = Double(monthly.consumerPriceIndex ?? 0)
                        em.values.append(Double(monthly.consumerPriceIndex ?? 0))
                        break
                    case "unemploymentPercent":
                        latestValue = Double(monthly.unemploymentPercent ?? 0)
                        em.values.append(Double(monthly.unemploymentPercent ?? 0))
                        break
                    case "fedFundsRate":
                        latestValue = Double(monthly.fedFundsRate ?? 0)
                        em.values.append(Double(monthly.fedFundsRate ?? 0))
                        break
                    case "industrialProductionIndex":
                        latestValue = Double(monthly.industrialProductionIndex ?? 0)
                        em.values.append(Double(monthly.industrialProductionIndex ?? 0))
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
