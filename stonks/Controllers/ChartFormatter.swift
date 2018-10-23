//
//  ChartFormatter.swift
//  stonks
//
//  Created by Samuel Hobel on 10/23/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import Foundation
import Charts

class ChartFormatter: NSObject, IAxisValueFormatter {
    
    private var xAxisLabels:[String] = []
    
    public func setXAxisLabels(_ labels:[String]){
        xAxisLabels = labels
    }
    
    public func resetXAxisLabels(){
        xAxisLabels.removeAll()
    }
    
    public func addXAxisLable(_ value: String){
        xAxisLabels.append(value)
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        if xAxisLabels.count >= Int(value) {
            return xAxisLabels[Int(value)]
        }
        return ""
    }
}
