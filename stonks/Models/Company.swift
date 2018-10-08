//
//  Company.swift
//  stonks
//
//  Created by Samuel Hobel on 9/27/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import Foundation

class Company: Equatable{

    public var ticker:String
    public var fullName:String
    public var currentPrice:Double?
    public var priceChange:Double?
    public var percentChange:Double?
    public var daysToER:Int?
    public var dailyData:[Date:Double]?
    public var minuteData:[String:Double]?
    
    init(ticker: String, fullName: String){
        self.ticker = ticker
        self.fullName = fullName
    }
    
    static func == (lhs: Company, rhs: Company) -> Bool {
        return lhs.ticker == rhs.ticker
    }
    
}
