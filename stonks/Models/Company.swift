//
//  Company.swift
//  stonks
//
//  Created by Samuel Hobel on 9/27/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import Foundation

class Company: Equatable, Comparable {

    public var isCompany:Bool //is either company or fund
    public var symbol:String
    public var fullName:String
    
    public var logo:String?
    public var generalInfo:GeneralInfo?
    public var keyStats:KeyStats?
    public var earnings:[Earnings]?
    public var estimates:Estimates?
    public var financials:Financials?
    
    public var recommendations:[Recommendations]?
    public var totalBuy:Int?
    public var totalHold:Int?
    public var totalSell:Int?
    
    public var priceTarget:PriceTarget?
    public var news:[News]?
    public var advancedStats: AdvancedStats?
    
    public var quote:Quote?
    public var earningsDate:Date?
    
//    public var quarterlyData:[Candle] = []
    public var monthlyData:[Candle] = []
    public var weeklyData:[Candle] = []
    public var dailyData:[Candle] = [] //daily candles
    public var minuteData:[Candle] = [] //minute candles
    public var sma50:[DatedValue] = []
    public var sma100:[DatedValue] = []
    public var sma200:[DatedValue] = []

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
    
    init(symbol:String, fullName:String, isCompany: Bool){
        self.symbol = symbol
        self.fullName = fullName
        self.isCompany = isCompany
    }
    
    //will fill in missing minutes as needed
    public func setMinuteData(_ dataSet: [Candle], open: Bool) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let startTime = "9:30 AM"
        let oneBeforeStart = "9:29 AM"
        var prevCandle:Candle = Candle()
        prevCandle.datetime = oneBeforeStart
        var returnDataSet: [Candle] = []
        for i in 0..<dataSet.count {
            let entry = dataSet[i]
            let curDate = NumberFormatter.timeStringToDate(entry.datetime!)
            if (entry.datetime != startTime){
                let prevDate = NumberFormatter.timeStringToDate(prevCandle.datetime!)
                let numMins = Int(curDate.timeIntervalSince(prevDate)/60)
                if numMins > 1 {
                    for j in 0..<numMins-1{
                        let calendar = Calendar.current
                        let newDate = calendar.date(byAdding: .minute, value: (j+1), to: prevDate)!
                        let newDateString = dateFormatter.string(from: newDate)
                        if i == 0{
                            let newCandle = Candle(datetime: newDateString, volume: 0, high: entry.close!, low: entry.close!, open: entry.close!, close: entry.close!)
                            returnDataSet.append(newCandle)
                        } else {
                            let newCandle = Candle(datetime: newDateString, volume: 0, high: prevCandle.close!, low: prevCandle.close!, open: prevCandle.close!, close: prevCandle.close!)
                            returnDataSet.append(newCandle)
                        }
                    }
                }
                returnDataSet.append(entry)
            }
            prevCandle = entry
        }
        if !open {
            let numToAdd = 391 - returnDataSet.count
            let lastEntry = returnDataSet[returnDataSet.count - 1]
            for x in 0..<numToAdd {
                let prevDate = NumberFormatter.timeStringToDate(lastEntry.datetime!)
                let calendar = Calendar.current
                let newDate = calendar.date(byAdding: .minute, value: (x+1), to: prevDate)!
                let newDateString = dateFormatter.string(from: newDate)
                let newCandle = Candle(datetime: newDateString, volume: 0, high: lastEntry.close!, low: lastEntry.close!, open: lastEntry.close!, close: lastEntry.close!)
                returnDataSet.append(newCandle)
            }
        }
        self.minuteData = returnDataSet
    }
    
    public func getDailyData(_ numDays: Int) -> [Candle]{
        return getDataSubset(dataset: dailyData, numDataPoints: numDays)
    }
    
    public func getWeeklyData(_ numWeeks: Int) -> [Candle]{
        return getDataSubset(dataset: weeklyData, numDataPoints: numWeeks)
    }
    
    public func getMonthlyData(_ numMonths: Int) -> [Candle] {
        return getDataSubset(dataset: monthlyData, numDataPoints: numMonths)
    }
    
    public func getQuarterlyData(_ numQuarters: Int) -> [Candle] {
        let dataset = getDataSubset(dataset: monthlyData, numDataPoints: numQuarters*4)
        var quarterlyData = shrinkDataSet(dataset, groupBy: 4)
        for index in 0..<quarterlyData.count {
            let candle = quarterlyData[index]
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yy"
            let date = dateFormatter.date(from: candle.datetime!)!
            dateFormatter.dateFormat = "yy"
            let year = dateFormatter.string(from: date)
            dateFormatter.dateFormat = "MMM"
            let month = dateFormatter.string(from: date)
            quarterlyData[index].datetime = month + " '" + year
        }
        return quarterlyData
    }
    
    public func addSmaToCandleSets(smaSet: [DatedValue], key:String){
        var dailyPointer = 0
        var weeklyPointer = 0
        var monthlyPointer = 0
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd"
        for i in 0..<smaSet.count {
            let sma = smaSet[i]
            let smaDate = dateformatter.string(from: sma.date!)
            var dailyDate = dateformatter.string(from: self.dailyData[dailyPointer].date!)
            var weeklyDate = dateformatter.string(from: self.weeklyData[weeklyPointer].date!)
            var monthlyDate = dateformatter.string(from: self.monthlyData[monthlyPointer].date!)
            //catch up all dates to sma date
            while self.dailyData[dailyPointer].date!.compare(sma.date!) == .orderedAscending {
                dailyPointer+=1
            }
            while self.weeklyData[weeklyPointer].date!.compare(sma.date!) == .orderedAscending {
                weeklyPointer+=1
            }
            while self.monthlyData[monthlyPointer].date!.compare(sma.date!) == .orderedAscending {
                monthlyPointer+=1
            }
            dailyDate = dateformatter.string(from: self.dailyData[dailyPointer].date!)
            weeklyDate = dateformatter.string(from: self.weeklyData[weeklyPointer].date!)
            monthlyDate = dateformatter.string(from: self.monthlyData[monthlyPointer].date!)
            if smaDate == dailyDate {
                switch key {
                    case "200":
                        self.dailyData[dailyPointer].sma200 = sma.value
                        break
                    case "50":
                        self.dailyData[dailyPointer].sma50 = sma.value
                        break
                    case "100":
                        self.dailyData[dailyPointer].sma100 = sma.value
                        break
                    default: break
                }
                dailyPointer+=1
            }
            if smaDate == weeklyDate {
                 switch key {
                     case "200":
                         self.weeklyData[weeklyPointer].sma200 = sma.value
                         break
                     case "50":
                         self.weeklyData[weeklyPointer].sma50 = sma.value
                         break
                     case "100":
                         self.weeklyData[weeklyPointer].sma100 = sma.value
                         break
                     default: break
                 }
                 weeklyPointer+=1
            }
            if smaDate == monthlyDate {
                switch key {
                     case "200":
                         self.monthlyData[monthlyPointer].sma200 = sma.value
                         break
                     case "50":
                         self.monthlyData[monthlyPointer].sma50 = sma.value
                         break
                     case "100":
                         self.monthlyData[monthlyPointer].sma100 = sma.value
                         break
                     default: break
                 }
                 monthlyPointer+=1
            }
        }
    }
    
    private func shrinkDataSet(_ chartData: [Candle], groupBy: Int) -> [Candle]{
        var dataSet:[Candle] = []
        var counter = 0
        var high = 0.0, low = 0.0, open = 0.0, volume = 0.0
        var date:String = ""
        for candle in chartData {
            counter += 1
            if counter == 1 {
                high = candle.high!
                low = candle.low!
                open = candle.open!
                volume = candle.volume!
                date = candle.datetime!
            } else {
                volume += candle.volume!
                if candle.high! > high {
                    high = candle.high!
                }
                if candle.low! < low {
                    low = candle.low!
                }
                if counter == groupBy {
                    let candle = Candle(datetime: date, volume: volume, high: high, low: low, open: open, close: candle.close!)
                    dataSet.append(candle)
                    counter = 0
                    volume = 0.0
                }
            }
        }
        return dataSet
    }
    
    private func getDataSubset(dataset: [Candle], numDataPoints: Int) -> [Candle] {
        if !dataset.isEmpty {
            if numDataPoints == 0 {
                return dataset
            }
            return Array(dataset.suffix(numDataPoints))
        }
        return []
    }
    
    static func == (lhs: Company, rhs: Company) -> Bool {
        return lhs.generalInfo?.symbol == rhs.generalInfo?.symbol
    }
    
    static func < (lhs: Company, rhs: Company) -> Bool {
        if let leftVal = lhs.quote?.changePercent, let rightVal = rhs.quote?.changePercent {
            return leftVal > rightVal
        }
        return false
    }
    
}
