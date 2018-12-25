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
        if num > 999999 {
            return String(format: "%.0f", num/1000000) + "M"
        }
        if num > 999 {
            return String(format: "%.0f", num/1000) + "K"
        }
        return String(num)
    }
}
