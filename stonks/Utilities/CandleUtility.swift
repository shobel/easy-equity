//
//  CandleUtility.swift
//  stonks
//
//  Created by Samuel Hobel on 2/22/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import Foundation

struct CandleUtility {
    
    static public func earningsIsInCandleDate(date: Date, prevDate: Date?, earnings: [Earnings], timeInterval: Constants.TimeIntervals) -> Earnings? {
        for e in earnings {
            if e.getDate() == date {
                return e
            }
        }
        if timeInterval != Constants.TimeIntervals.day && timeInterval != Constants.TimeIntervals.one_month && timeInterval != Constants.TimeIntervals.three_month {
            if prevDate != nil {
                for e in earnings {
                    let compCurrCandle = e.getDate()?.compare(date)
                    let compPrevCandle = e.getDate()?.compare(prevDate!)
                    if compCurrCandle!.rawValue == -1 && compPrevCandle!.rawValue == 1 {
                        return e
                    }
                }
            }
            var prevDate = Calendar.current.date(byAdding: .day, value: -1, to: date)!
            if timeInterval == Constants.TimeIntervals.one_year {
                prevDate = Calendar.current.date(byAdding: .day, value: -7, to: date)!
            } else if timeInterval == Constants.TimeIntervals.five_year {
                prevDate = Calendar.current.date(byAdding: .month, value: -1, to: date)!
            } else if timeInterval == Constants.TimeIntervals.twenty_year {
                prevDate = Calendar.current.date(byAdding: .day, value: -4, to: date)!
            }
            for e in earnings {
                let compCurrCandle = e.getDate()?.compare(date)
                let prevComp = e.getDate()?.compare(prevDate)
                if compCurrCandle!.rawValue == -1 && prevComp!.rawValue == 1 {
                    return e
                }
            }
        }
        return nil
    }
}
