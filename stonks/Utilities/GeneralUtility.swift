//
//  GeneralUtility.swift
//  stonks
//
//  Created by Samuel Hobel on 2/24/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import Foundation

struct GeneralUtility {
    
    static public func daysUntil(date: Date) -> Int {
        let days: Set<Calendar.Component> = [.day]
        let difference = Calendar.current.dateComponents(days, from: Date(), to: date)
        return difference.day ?? 0
    }
}
