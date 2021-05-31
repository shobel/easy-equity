//
//  CandleUtility.swift
//  stonks
//
//  Created by Samuel Hobel on 2/22/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import Foundation

struct CandleUtility {
    
    static public func earningsIsInCandleDate(date: Date, prevDate: Date?, earnings: Earnings, timeInterval: Constants.TimeIntervals) -> Bool {
        if earnings.getDate() == date {
            return true
        }
        if timeInterval != Constants.TimeIntervals.day && timeInterval != Constants.TimeIntervals.one_month && timeInterval != Constants.TimeIntervals.three_month {
            if prevDate != nil {
                let compCurrCandle = earnings.getDate()?.compare(date)
                let compPrevCandle = earnings.getDate()?.compare(prevDate!)
                if compCurrCandle!.rawValue == -1 && compPrevCandle!.rawValue == 1 {
                    return true
                }
            }
            var prevDate = Calendar.current.date(byAdding: .day, value: -2, to: date)!
            if timeInterval == Constants.TimeIntervals.one_year {
                prevDate = Calendar.current.date(byAdding: .day, value: -8, to: date)!
            } else if timeInterval == Constants.TimeIntervals.five_year {
                prevDate = Calendar.current.date(byAdding: .month, value: -1, to: date)!
            }
            let compCurrCandle = earnings.getDate()?.compare(date)
            let prevComp = earnings.getDate()?.compare(prevDate)
            if compCurrCandle!.rawValue == -1 && prevComp!.rawValue == 1 {
                return true
            }
        }
        return false
    }
}
