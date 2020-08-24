//
//  PriceChartPreviewView.swift
//  stonks
//
//  Created by Samuel Hobel on 8/22/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import UIKit
import Charts

class PriceChartPreviewView: LineChartView {
   
    public func setup(){
        self.chartDescription?.enabled = false
        self.legend.enabled = false
        self.dragEnabled = false
        self.setScaleEnabled(false)
        self.pinchZoomEnabled = false
        self.doubleTapToZoomEnabled = false
        self.autoScaleMinMaxEnabled = true
        
        self.leftAxis.enabled = false
        self.rightAxis.enabled = false
        self.xAxis.enabled = false
    }
    
    public func setData(data: [Double], color: UIColor){
        var lineEntries:[ChartDataEntry] = []
        for i in 0..<data.count {
            lineEntries.append(ChartDataEntry(x: Double(i), y: data[i]))
        }
        let lineChartDataSet = LineChartDataSet(entries: lineEntries)
        lineChartDataSet.drawCirclesEnabled = false
        lineChartDataSet.drawCircleHoleEnabled = false
        lineChartDataSet.drawValuesEnabled = false
        lineChartDataSet.drawFilledEnabled = false
        lineChartDataSet.setColor(color)
        
        DispatchQueue.main.async {
            self.data = LineChartData(dataSet: lineChartDataSet)
            self.xAxis.axisMaximum = self.data!.xMax + 10
            self.notifyDataSetChanged()
        }
    }
}
