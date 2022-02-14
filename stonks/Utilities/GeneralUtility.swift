//
//  GeneralUtility.swift
//  stonks
//
//  Created by Samuel Hobel on 2/24/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import Foundation

struct GeneralUtility {
    
    public static func isPasswordValid(_ password: String) -> Bool {
        //let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        //return passwordTest.evaluate(with: password)
        return password.trimmingCharacters(in: .whitespacesAndNewlines).count >= 8
    }
    
    public static func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    public static func daysUntil(date: Date) -> Int {
        let days: Set<Calendar.Component> = [.day]
        let difference = Calendar.current.dateComponents(days, from: Date(), to: date)
        return difference.day ?? 0
    }
    
    public static func timestampToDateString(_ timestamp:Int) -> String{
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
        dateFormatter.timeZone = .current
        let localDate = dateFormatter.string(from: date)
        return localDate
    }
    
    //format month/day/year
    public static func stringToDate(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        return dateFormatter.date(from: dateString)
    }
    
    /* iso string format example: 2020-10-27T17:09:22Z */
    public static func isoDateToTimestamp(isoString:String) -> Double {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        if let newdate = formatter.date(from: isoString) {
            return newdate.timeIntervalSince1970
        } else {
            return 0.0
        }
    }
    
    public static func isPremarket() -> Bool{
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.init(abbreviation: "EST")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = formatter.string(from: now)
        let etDate = formatter.date(from: dateString)
        
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.init(abbreviation: "EST")!
        let nine_thirty_am = calendar.date(
            bySettingHour: 9,
            minute: 30,
            second: 0,
            of: now)!
        let six_am = calendar.date(
            bySettingHour: 6,
            minute: 0,
            second: 0,
            of: now)!
        if calendar.isDateInWeekend(etDate!) {
            return false
        }
        if etDate! < nine_thirty_am && etDate! > six_am {
            return true
        }
        return false
    }
    
    public static func isAftermarket() -> Bool{
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.init(abbreviation: "EST")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = formatter.string(from: now)
        let etDate = formatter.date(from: dateString)
           
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.init(abbreviation: "EST")!
        let four = calendar.date(
            bySettingHour: 16,
            minute: 0,
            second: 0,
            of: now)!
        let eight = calendar.date(
            bySettingHour: 20,
            minute: 0,
            second: 0,
            of: now)!
        if calendar.isDateInWeekend(etDate!) {
            return false
        }
        if etDate! > four && etDate! < eight {
            return true
        }
        return false
    }
    
}
