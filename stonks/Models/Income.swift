//
//  Financials.swift
//  stonks
//
//  Created by Samuel Hobel on 9/2/19.
//  Copyright © 2019 Samuel Hobel. All rights reserved.
//

import Foundation
import ObjectMapper

struct Income: Mappable {
        
    public var reportDate:String? //"2019-03-31",
    public var fiscalDate:String? //"2019-03-31"
    public var researchAndDevelopment:Int?
    public var costOfRevenue:Int?
    public var operatingExpense:Int?
    public var operatingIncome:Int?
    
    init(){}
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        reportDate <- map["reportDate"]
        fiscalDate <- map["fiscalDate"]
        costOfRevenue <- map["costOfRevenue"]
        operatingIncome <- map["operatingIncome"]
        researchAndDevelopment <- map["researchAndDevelopment"]
        operatingExpense <- map["operatingExpense"]
    }
    
}
