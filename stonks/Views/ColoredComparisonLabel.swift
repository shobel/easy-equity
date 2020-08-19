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
    
    public func setValue(value: Double, comparisonValue: Double){
        let diff = value - comparisonValue
        self.textColor = getColor(diff)
        let formattedValue = NumberFormatter.formatNumberWithPossibleDecimal(value)
        let percentString = NumberFormatter.formatNumberWithPossibleDecimal((diff / comparisonValue) * 100.0)
        self.text = String("\(formattedValue) (\(percentString)%)")
    }

}
