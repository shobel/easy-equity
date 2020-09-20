//
//  Earnings.swift
//  stonks
//
//  Created by Samuel Hobel on 9/2/19.
//  Copyright © 2019 Samuel Hobel. All rights reserved.
//

import Foundation
import ObjectMapper

struct Earnings: Mappable {
    //1,000 points
    
    public var actualEPS:Double? //2.46,
    public var consensusEPS:Double? //2.36,
    public var announceTime:String? //"AMC",
    public var numberOfEstimates:Int? //34,
    public var EPSSurpriseDollar:Double? //0.1,
    public var EPSReportDate:String? //"2019-04-30", yyy-MM-dd
    public var fiscalPeriod:String? //"Q1 2019",
    public var fiscalEndDate:String? //"2019-03-31",
    public var yearAgo:Double? //2.73,
    public var yearAgoChangePercent:Double? //-0.0989
    public var revenue:Double?
    public var revenueEstimated:Double?
    
    private var dateFormat:String = "yyyy-MM-dd"
    
    init(){}
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        actualEPS <- map["actualEPS"]
        consensusEPS <- map["consensusEPS"]
        announceTime <- map["announceTime"]
        numberOfEstimates <- map["numberOfEstimates"]
        EPSSurpriseDollar <- map["EPSSurpriseDollar"]
        EPSReportDate <- map["EPSReportDate"]
        fiscalPeriod <- map["fiscalPeriod"]
        yearAgo <- map["yearAgo"]
        yearAgoChangePercent <- map["yearAgoChangePercent"]
        revenue <- map["revenue"]
        revenueEstimated <- map["revenueEstimated"]
    }
    
    public func getDate() -> Date? {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = self.dateFormat
        if let epsReportDate = self.EPSReportDate {
            return dateformatter.date(from: epsReportDate)
        }
        return nil
    }
    
    public func getDateString(from: Date) -> String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = self.dateFormat
        return dateformatter.string(from: from)
    }
}
