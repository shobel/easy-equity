//
//  ColoredPercentLabel.swift
//  stonks
//
//  Created by Samuel Hobel on 10/9/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import UIKit

class ColoredPercentLabel: UILabel {

    private var changePercent: Double?
    
    /*
    override func draw(_ rect: CGRect) {
    }
    */
    
    private func getFormattedString() -> String {
        if changePercent == nil {
            return "0.0 (0.0%)"
        }
        var sign = ""
        if changePercent! > 0.0 {
            sign = "+"
        }
        return sign + String(format: "%.2f", changePercent!) + "%"
    }
    
    private func getColor(value: Double?) -> UIColor{
        if value == nil {
            return UIColor.black
        }
        
        if value! < 0.0 {
            return Constants.darkPink
        }
        return Constants.green
    }
    
    public func setPriceChange(percent: Double){
        self.changePercent = percent
        
        self.textColor = getColor(value: percent)
        self.text = getFormattedString()
    }

}
