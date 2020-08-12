//
//  AdvancedStats.swift
//  stonks
//
//  Created by Samuel Hobel on 9/7/19.
//  Copyright © 2019 Samuel Hobel. All rights reserved.
//

import Foundation
import ObjectMapper

struct AdvancedStats: Mappable {
   
    public var putCallRatio:Double?
    public var currentDebt:Int? //20748000000,
    public var totalCash:Int? //66301000000,
    public var revenue:Int? //265809000000,
    public var grossProfit:Int? //101983000000,
    public var ebitda:Int? //80342000000,
    public var revenuePerShare:Double? //0.02,
    public var revenuePerEmployee:Double? //2013704.55,
    public var debtToEquity:Double? //1.07,
    public var profitMargin:Double? //22.396157,
    public var enterpriseValue:Int? //1022460690000,
    public var enterpriseValueToRevenue:Double? //3.85
    public var priceToSales:Double? //3.49,
    public var priceToBook:Double? //8.805916432564608,
    public var forwardPERatio:Double? //18.14,
    public var pegRatio:Double? //2.19,
    
    init(){}
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        totalCash <- map["totalCash"]
        currentDebt <- map["currentDebt"]
        revenue <- map["revenue"]
        grossProfit <- map["grossProfit"]
        ebitda <- map["EBITDA"]
        revenuePerShare <- map["revenuePerShare"]
        revenuePerEmployee <- map["revenuePerEmployee"]
        debtToEquity <- map["debtToEquity"]
        profitMargin <- map["profitMargin"]
        enterpriseValue <- map["enterpriseValue"]
        enterpriseValueToRevenue <- map["enterpriseValueToRevenue"]
        priceToSales <- map["priceToSales"]
        priceToBook <- map["priceToBook"]
        forwardPERatio <- map["forwardPERatio"]
        pegRatio <- map["pegRatio"]
        putCallRatio <- map["putCallRatio"]
    }
}
