//
//  ColoredValueLabel.swift
//  stonks
//
//  Created by Samuel Hobel on 10/9/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import UIKit

class ColoredValueLabel: UILabel {

    private var changeValue: Double = 0.0
    private var prefix:String = ""
    private var isPercent:Bool = false
    /*
    override func draw(_ rect: CGRect) {
    }
    */
    
    private func getFormattedString() -> String {
        var sign = ""
        if changeValue > 0.0 {
            sign = "+"
        }
        var suffix = ""
        if isPercent {
            suffix = "%"
        }
        if prefix.isEmpty {
            return sign + String(format: "%.2f", changeValue) + suffix
        }
        return prefix + " " + sign + String(format: "%.2f", changeValue) + suffix
    }
    
    public func getColor(value: Double?) -> UIColor{
        if value == nil {
            return UIColor.black
        }
        
        if value! < 0.0 {
            return Constants.darkPink
        }
        return Constants.green
    }
    
    //weird rule: if value is Int.min, will set the text to ---- in gray
    public func setValue(value: Double, isPercent: Bool, prefix:String = ""){
        if value == Double(Int.min) {
            self.textColor = .gray
            self.text = "---"
        } else {
            self.changeValue = value
            self.isPercent = isPercent
            self.prefix = prefix
            
            self.textColor = getColor(value: value)
            self.text = getFormattedString()
        }
    }

}
