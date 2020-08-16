//
//  ColoredComparisonLabel.swift
//  stonks
//
//  Created by Samuel Hobel on 8/14/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import UIKit

class ColoredComparisonLabel: UILabel {

    public func getColor(_ value: Double?) -> UIColor{
        if value == nil || value == 0.0{
            return UIColor.black
        }
        
        if value! < 0.0 {
            return Constants.darkPink
        }
        return Constants.green
    }
    
    func formatNumber(_ value:Double) -> String{
        let dbl = value
        let isInteger = floor(dbl) == dbl
        if isInteger {
            return String(Int(value.rounded()))
        } else {
            return String(format:"%.2f", value)
        }
    }
    
    public func setValue(value: Double, comparisonValue: Double){
        let diff = value - comparisonValue
        self.textColor = getColor(diff)
        let formattedValue = self.formatNumber(value)
        let percentString = self.formatNumber((diff / comparisonValue) * 100.0)
        self.text = String("\(formattedValue) (\(percentString)%)")
    }

}
