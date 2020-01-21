//
//  Financials.swift
//  stonks
//
//  Created by Samuel Hobel on 9/2/19.
//  Copyright © 2019 Samuel Hobel. All rights reserved.
//

import Foundation
import ObjectMapper

struct Financials: Mappable {
    
    // 5,000 points
    
    public var reportDate:String? //"2019-03-31",
    public var grossProfit:Int? //21648000000,
    public var costOfRevenue:Int? //36270000000,
    public var operatingRevenue:Int? //57918000000,
    public var totalRevenue:Int? //57918000000,
    public var operatingIncome:Int? //13242000000,
    public var netIncome:Int? //11561000000,
    public var researchAndDevelopment:Int? //3948000000,
    public var operatingExpense:Int? //44676000000,
    public var currentAssets:Int? //123346000000,
    public var totalAssets:Int? //341998000000,
    public var totalLiabilities:Int? //236138000000,
    public var currentCash:Int? //38329000000,
    public var currentDebt:Int? //22429000000,
    public var shortTermDebt:Int? //22429000000,
    public var longTermDebt:Int? //90201000000,
    public var totalCash:Int? //80433000000,
    public var totalDebt:Int? //112630000000,
    public var shareholderEquity:Int? //105860000000,
    public var cashChange:Int? //-4954000000,
    public var cashFlow:Int? //11155000000
    
    init(){}
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        reportDate <- map["reportDate"]
        grossProfit <- map["grossProfit"]
        costOfRevenue <- map["costOfRevenue"]
        operatingRevenue <- map["operatingRevenue"]
        totalRevenue <- map["totalRevenue"]
        operatingIncome <- map["operatingIncome"]
        netIncome <- map["netIncome"]
        researchAndDevelopment <- map["researchAndDevelopment"]
        operatingExpense <- map["operatingExpense"]
        currentAssets <- map["currentAssets"]
        totalAssets <- map["totalAssets"]
        totalLiabilities <- map["totalLiabilities"]
        currentCash <- map["currenCash"]
        currentDebt <- map["currentDebt"]
        shortTermDebt <- map["shortTermDebt"]
        longTermDebt <- map["longTermDebt"]
        totalCash <- map["totalCash"]
        totalDebt <- map["totalDebt"]
        shareholderEquity <- map["shareholderEquity"]
        cashChange <- map["cashChange"]
        cashFlow <- map["cashFlow"]
    }
    
}
