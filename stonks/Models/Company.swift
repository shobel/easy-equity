//
//  Company.swift
//  stonks
//
//  Created by Samuel Hobel on 9/27/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import Foundation

class Company: Equatable{

    public var isCompany:Bool //is either company or fund
    public var ticker:String
    public var fullName:String
    public var ceo:String?
    public var description:String?
    public var logo:String?
    public var quote:Quote?
    public var earningsDate:Date?
    public var dailyData:[Date:Double]?
    public var minuteData:[String:Double]?
    public var analystsRating:AnalystsRating?
    
    public var daysToER:Int {
        if let erDate = earningsDate {
            var calendar = Calendar.current
            calendar.timeZone = TimeZone.init(abbreviation: "EST")!
            let er = calendar.startOfDay(for: erDate)
            let diffInDays = Calendar.current.dateComponents([.day], from: Date(), to: er).day
            return diffInDays!
        }
        return -1
    }
    
    init(ticker: String, fullName: String, isCompany: Bool){
        self.ticker = ticker
        self.fullName = fullName
        self.isCompany = isCompany
    }
    
    static func == (lhs: Company, rhs: Company) -> Bool {
        return lhs.ticker == rhs.ticker
    }
    
}
