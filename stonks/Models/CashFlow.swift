//
//  Financials.swift
//  stonks
//
//  Created by Samuel Hobel on 9/2/19.
//  Copyright © 2019 Samuel Hobel. All rights reserved.
//

import Foundation
import ObjectMapper

struct CashFlow: Mappable {
        
    public var reportDate:String? //"2019-03-31",
    public var fiscalDate:String? //"2019-03-31"
    public var netIncome:Int?
    public var cashChange:Int?
    public var cashFlow:Int?
    public var capitalExpenditures:Int?
    public var dividendsPaid:Int?
    
    init(){}
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        reportDate <- map["reportDate"]
        fiscalDate <- map["fiscalDate"]
        netIncome <- map["netIncome"]
        cashChange <- map["cashChange"]
        cashFlow <- map["cashFlow"]
        capitalExpenditures <- map["capitalExpenditures"]
        dividendsPaid <- map["dividendsPaid"]
    }
    
}
