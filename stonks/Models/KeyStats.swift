//
//  KeyStats.swift
//  stonks
//
//  Created by Samuel Hobel on 8/25/19.
//  Copyright © 2019 Samuel Hobel. All rights reserved.
//

import Foundation
import ObjectMapper

struct KeyStats: Mappable {
    public var marketcap:Int? //760334287200,
    public var avg10Volume:Int? //2774000,
    public var avg30Volume:Int? //12774000,
    public var peRatio:Int? //14,
    public var ttmEPS:Double? //16.5,
    public var ttmDividendRate:Double? //2.25,
    public var dividendYield:Double? //.021,
    public var beta:Double? //1.25,
    public var sharesOutstanding:Int? //5213840000,
    public var float:Int? //5203997571,
    public var nextDividendDate:String? //'2019-03-01',
    public var nextEarningsDate:String? //'2019-01-01',
    
    init(){}
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        marketcap <- map["marketcap"]
        ttmDividendRate <- map["ttmDividendRate"]
        dividendYield <- map["dividendYield"]
        beta <- map["beta"]
        ttmEPS <- map["ttmEPS"]
        peRatio <- map["peRatio"]
        float <- map["float"]
        avg30Volume <- map["avg30Volume"]
        avg10Volume <- map["avg10Volume"]
        sharesOutstanding <- map["sharesOutstanding"]
        nextDividendDate <- map["nextDividentDate"]
        nextEarningsDate <- map["nextEarningsDate"]
    }
    
    public func getNextEarningsDate() -> Date? {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd"
        if let ed = self.nextEarningsDate {
            return dateformatter.date(from: ed)
        }
        return nil
    }
    
}
