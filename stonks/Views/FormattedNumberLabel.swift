//
//  FormattedNumberLabel.swift
//  stonks
//
//  Created by Samuel Hobel on 9/12/19.
//  Copyright © 2019 Samuel Hobel. All rights reserved.
//

import UIKit

class FormattedNumberLabel: UILabel {

    enum Format {
        case NUMBER, DATE, PERCENT
    }
    
    private var value:String = ""
    
    public func setValue(value:String, format:Format){
        self.value = value
        switch (format){
        case Format.NUMBER:
            self.text = NumberFormatter.formatNumber(num: Double(value)!)
        case Format.DATE:
            self.text = NumberFormatter.formatDate(value)
        case Format.PERCENT:
            self.text = NumberFormatter.formatPercent(value: value)
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
