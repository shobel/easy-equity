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
    public var employees:Int? //120000,
    
    public var marketcap:Int? //760334287200,
    public var peRatio:Int? //14,
    public var peHigh:Double? //13.131
    public var peLow:Double? //12343.31432
    public var beta:Double? //1.25,
    public var sharesOutstanding:Int? //5213840000,
    public var float:Int? //5203997571,
    
    public var ttmEPS:Double? //16.5,
    public var ttmDividendRate:Double? //2.25,
    public var dividendYield:Double? //.021,
    public var nextDividendDate:String? //'2019-03-01',
    public var exDividendDate:String? //'2019-02-08',
    public var nextEarningsDate:String? //'2019-01-01',
    
    public var week52high:Double? //156.65,
    public var week52low:Double? //93.63,
    public var week52change:Double? //58.801903,
    public var avg10Volume:Int? //2774000,
    public var avg30Volume:Int? //12774000,
    public var day200MovingAvg:Double? //140.60541,
    public var day50MovingAvg:Double? //156.49678,
    public var maxChangePercent:Double? //153.021,
    public var year5ChangePercent:Double? //0.5902546932200027,
    public var year2ChangePercent:Double? //0.3777449874142869,
    public var year1ChangePercent:Double? //0.39751716851558366,
    public var ytdChangePercent:Double? //0.36659492036160124,
    public var month6ChangePercent:Double? //0.12208398133748043,
    public var month3ChangePercent:Double? //0.08466584665846649,
    public var month1ChangePercent:Double? //0.009668596145283263,
    public var day30ChangePercent:Double? //-0.002762605699968781,
    public var day5ChangePercent:Double? //-0.005762605699968781
    
    init(){}
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        employees <- map["employees"]
        marketcap <- map["marketcap"]
        peRatio <- map["peRatio"]
        peHigh <- map["peHigh"]
        peLow <- map["peLow"]
        beta <- map["beta"]
        sharesOutstanding <- map["sharesOutstanding"]
        float <- map["float"]
        ttmEPS <- map["ttmEPS"]
        ttmDividendRate <- map["ttmDividendRate"]
        dividendYield <- map["dividendYield"]
        nextDividendDate <- map["nextDividentDate"]
        exDividendDate <- map["exDividendDate"]
        nextEarningsDate <- map["nextEarningsDate"]
        week52low <- map["week52low"]
        week52high <- map["week52high"]
        week52change <- map["week52change"]
        avg10Volume <- map["avg10Volume"]
        avg30Volume <- map["avg30Volume"]
        day50MovingAvg <- map["day50MovingAvg"]
        day200MovingAvg <- map["day200MovingAvg"]
        maxChangePercent <- map["maxChangePercent"]
        year5ChangePercent <- map["year5ChangePercent"]
        year2ChangePercent <- map["year2ChangePercent"]
        year1ChangePercent <- map["year1ChangePercent"]
        ytdChangePercent <- map["ytdChangePercent"]
        month1ChangePercent <- map["month1ChangePercent"]
        month3ChangePercent <- map["month3ChangePercent"]
        month6ChangePercent <- map["month6ChangePercent"]
        day30ChangePercent <- map["day30ChangePercent"]
        day5ChangePercent <- map["day5ChangePercent"]
    }
}
