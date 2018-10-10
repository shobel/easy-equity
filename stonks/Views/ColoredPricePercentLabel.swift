//
//  ColoredPricePercentLabel.swift
//  stonks
//
//  Created by Samuel Hobel on 10/10/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import UIKit

class ColoredPricePercentLabel: UILabel {

    private var change: Double?
    private var changePercent: Double?
    
    /*
     override func draw(_ rect: CGRect) {
     }
     */
    
    private func getFormattedString() -> String {
        if change == nil {
            return "0.0 (0.0%)"
        }
        var sign = ""
        if change! > 0.0 {
            sign = "+"
        }
        return sign + String(format: "%.2f", change!) + " (" + String(format: "%.2f", changePercent!) + ")%"
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
    
    public func setPriceChange(price: Double, percent: Double){
        self.change = price
        self.changePercent = abs(percent)
        
        self.textColor = getColor(value: change)
        self.text = getFormattedString()
    }

}
