//
//  GeneralUtility.swift
//  stonks
//
//  Created by Samuel Hobel on 2/24/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import Foundation

struct GeneralUtility {
    
    static func isPasswordValid(_ password: String) -> Bool {
        //let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        //return passwordTest.evaluate(with: password)
        return password.trimmingCharacters(in: .whitespacesAndNewlines).count >= 8
    }
    
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    static public func daysUntil(date: Date) -> Int {
        let days: Set<Calendar.Component> = [.day]
        let difference = Calendar.current.dateComponents(days, from: Date(), to: date)
        return difference.day ?? 0
    }
}
