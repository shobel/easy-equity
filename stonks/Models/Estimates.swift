//
//  Estimates.swift
//  stonks
//
//  Created by Samuel Hobel on 9/2/19.
//  Copyright © 2019 Samuel Hobel. All rights reserved.
//

import Foundation
import ObjectMapper
struct Estimates: Mappable {
    //very expensive 10,000
    
    public var consensusEPS:Double? //2.02,
    public var numberOfEstimates:Int? //14,
    public var fiscalPeriod:String? //"Q2 2017",
    public var fiscalEndDate:String? //"2017-03-31",
    public var reportDate:String? //"2017-04-15",
    public var announceTime:String? //"AMC"
    
    init(){}
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        consensusEPS <- map["consensusEPS"]
        numberOfEstimates <- map["numberOfEstimates"]
        fiscalPeriod <- map["fiscalPeriod"]
        fiscalEndDate <- map["fiscalEndDate"]
        reportDate <- map["reportDate"]
        announceTime <- map["announceTime"]
    }
    
    public func getDate() -> Date? {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd"
        if let rd = self.reportDate {
            return dateformatter.date(from: rd)
        }
        return nil
    }
}
