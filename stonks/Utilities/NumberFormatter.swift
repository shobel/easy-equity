//
//  NumberFormatter.swift
//  stonks
//
//  Created by Samuel Hobel on 12/21/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import Foundation

class NumberFormatter {
    
    static func formatNumber(num:Double) -> String {
        if abs(num) > 999999999 {
            return String(format: "%.0f", num/1000000000) + "B"
        }
        if abs(num) > 999999 {
            return String(format: "%.0f", num/1000000) + "M"
        }
        if abs(num) > 999 {
            return String(format: "%.0f", num/1000) + "K"
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
    
    static func formatPercent(value:String) -> String{
        return String(format: "%.2f", Double(value)! * 100) + "%"
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
