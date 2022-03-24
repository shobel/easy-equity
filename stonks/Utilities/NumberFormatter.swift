//
//  NumberFormatter.swift
//  stonks
//
//  Created by Samuel Hobel on 12/21/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import Foundation

class NumberFormatter {
    
    /* formats a number to be a double if it has a decimal, otherwise an integer */
    static func formatNumberWithPossibleDecimal(_ value:Double) -> String {
        var dbl = value
        if ceil(value) - value < 0.02 {
            dbl = ceil(value)
        } else if value - floor(value) < 0.02 {
            dbl = floor(value)
        }
        let isInteger = floor(dbl) == dbl
        if isInteger {
            return String(Int(value.rounded()))
        } else {
            return String(format:"%.2f", value)
        }
    }
    
    //dates in the format YYYY-MM-DD or YYYY/MM/DD can be converted to Ints with this method
    static func convertStringDateToInt(date:String) -> Int {
        if date.contains("-"){
            if let dateInt = Int(date.replacingOccurrences(of: "-", with: "")) {
                return dateInt
            }
        }
        if date.contains("/") {
            if let dateInt = Int(date.replacingOccurrences(of: "/", with: "")) {
                return dateInt
            }
        }
        return 0
    }
    
    /* Formats a number to be an integer with the appropriate suffix */
    static func formatNumber(num:Double) -> String {
        if abs(num) > 999999999999 {
            return String(format: "%.1f", num/1000000000000) + "T"
        }
        if abs(num) > 999999999 {
            return String(format: "%.1f", num/1000000000) + "B"
        }
        if abs(num) > 999999 {
            return String(format: "%.1f", num/1000000) + "M"
        }
        if abs(num) > 999 {
            return String(format: "%.2f", num/1000) + "K"
        }
        if (num - floor(num) > 0.000001) { // 0.000001 can be changed depending on the level of precision you need
            return String(format: "%.2f", num)
        }
        return String(format: "%.0f", num)
    }
    
    static func formatDate(_ dateString:String) -> String {
        if (dateString.contains("-")){
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.timeZone = TimeZone(identifier: "PST")
            let date = dateFormatter.date(from:dateString)!
            dateFormatter.dateFormat = "MM/dd/yy"
            return dateFormatter.string(from: date)
        }
        if dateString.contains("AM") || dateString.contains("PM") || !dateString.contains(","){
            return dateString
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yy"
        dateFormatter.timeZone = TimeZone(identifier: "PST")
        let date = dateFormatter.date(from:dateString)!
        dateFormatter.dateFormat = "MM/dd/yy"
        return dateFormatter.string(from: date)
    }
    
    static func formatDateToYearMonthDayDashesString(_ date:Date) -> String{
        let today = Date()
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "YYYY-MM-dd"
        return formatter1.string(from: today)
    }
    
    static func formatPercent(value:String) -> String{
        return String(format: "%.2f", Double(value)! * 100) + "%"
    }
    
    //date string argument is in format of YYYY-MM-dd
    static func formatDateToMonthYearShort(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let date = dateFormatter.date(from: dateString)!
        dateFormatter.dateFormat = "yy"
        let year = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "MMM"
        let month = dateFormatter.string(from: date)
        return month + " '" + year
    }
    
    //input is of the format HH:mm AM/PM, minutes don't appear if they are 00 i.g. 10 AM
    static func timeStringToDate(_ timeString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        var hours:Int = 0
        let minutes:String = "00"
        var amPM = "AM"
        if !timeString.contains(":") {
            let split = timeString.split(separator: " ")
            hours = Int(split[0])!
            amPM = String(split[1])
            let finalTimeString = "\(hours):\(minutes) \(amPM)"
            return dateFormatter.date(from: finalTimeString)!
        }
        return dateFormatter.date(from: timeString)!
    }
    
    static func timestampToDatestring(_ timestamp: Double) -> String {
        var adjTimestamp = timestamp
        if adjTimestamp > 9999999999 {
            adjTimestamp = timestamp / 1000
        }
        let date = Date(timeIntervalSince1970: adjTimestamp)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "EST") //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "MMM dd, YYYY" //Specify your format that you want
        let strDate = dateFormatter.string(from: date)
        return strDate
    }
}

extension String {
    static let shortDateUS: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateStyle = .short
        return formatter
    }()
    var shortDateUS: Date? {
        return String.shortDateUS.date(from: self)
    }
}
