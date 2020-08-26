//
//  RSIChart.swift
//  stonks
//
//  Created by Samuel Hobel on 8/23/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import UIKit
import Charts

class RSIChart: LineChartView {
     
    public func setData(data: [Candle]){
    
        self.chartDescription?.enabled = false
        self.legend.enabled = false
        self.dragEnabled = false
        self.setScaleEnabled(false)
        self.pinchZoomEnabled = false
        self.doubleTapToZoomEnabled = false
        self.autoScaleMinMaxEnabled = true
        
        self.leftAxis.enabled = false
        self.rightAxis.enabled = true
        self.rightAxis.drawAxisLineEnabled = false
        self.rightAxis.drawGridLinesEnabled = false
        self.rightAxis.labelCount = 4
        self.rightAxis.axisMinimum = 0.0
        self.xAxis.enabled = false
        
        var lineEntries:[ChartDataEntry] = []
        for i in 0..<data.count {
            if let rsi = data[i].rsi14 {
                lineEntries.append(ChartDataEntry(x: Double(i), y: rsi))
            }
        }
        let lineChartDataSet = LineChartDataSet(entries: lineEntries)
        lineChartDataSet.drawCirclesEnabled = false
        lineChartDataSet.drawCircleHoleEnabled = false
        lineChartDataSet.drawValuesEnabled = false
        lineChartDataSet.drawFilledEnabled = false
        lineChartDataSet.setColor(.brown)
                 
        DispatchQueue.main.async {
            self.data = LineChartData(dataSet: lineChartDataSet)
            self.notifyDataSetChanged()
        }
     }
}
