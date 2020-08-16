//
//  SimpleColoredLabel.swift
//  stonks
//
//  Created by Samuel Hobel on 8/14/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import UIKit

class SimpleColoredLabel: UILabel {
    
    public func getColor(value: Double?) -> UIColor{
        if value == nil || value == 0.0{
            return UIColor.black
        }
        
        if value! < 0.0 {
            return Constants.darkPink
        }
        return Constants.green
    }
    
    public func setValue(value: Double, prefix:String, suffix:String){
        self.textColor = getColor(value: value)
        let formattedValue = String(format: "%.2f", value)
        self.text = String("\(prefix)\(formattedValue)\(suffix)")
    }
}
