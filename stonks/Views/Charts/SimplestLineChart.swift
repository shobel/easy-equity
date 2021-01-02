//
//  PriceChartPreviewView.swift
//  stonks
//
//  Created by Samuel Hobel on 8/22/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import UIKit
import Charts

class SimplestLineChart: LineChartView {
   
    public func setup(){
        self.chartDescription?.enabled = false
        self.legend.enabled = false
        self.dragEnabled = false
        self.isUserInteractionEnabled = false
        self.setScaleEnabled(false)
        self.pinchZoomEnabled = false
        self.doubleTapToZoomEnabled = false
        self.autoScaleMinMaxEnabled = true
        
        self.leftAxis.enabled = true
        self.leftAxis.drawAxisLineEnabled = true
        self.leftAxis.labelPosition = .insideChart
        self.leftAxis.labelCount = 2
        self.leftAxis.drawGridLinesEnabled = false
        self.leftAxis.valueFormatter = BigNumberAxisFormatter()
        self.rightAxis.enabled = false
        self.xAxis.enabled = false
        self.noDataText = ""
    }
    
    public func setData(_ data: [Double]){
        self.setup()
        
        var lineEntries:[ChartDataEntry] = []
        for i in 0..<data.count {
            lineEntries.append(ChartDataEntry(x: Double(i), y: data[i]))
        }
        let lineChartDataSet = LineChartDataSet(entries: lineEntries)
        lineChartDataSet.drawCirclesEnabled = false
        lineChartDataSet.drawCircleHoleEnabled = false
        lineChartDataSet.drawValuesEnabled = false
        lineChartDataSet.drawFilledEnabled = false
        lineChartDataSet.setColor(Constants.darkGrey)
        
        DispatchQueue.main.async {
            self.data = LineChartData(dataSet: lineChartDataSet)
            self.notifyDataSetChanged()
        }
    }
    
    public func setDrawZeroLine(){
        self.leftAxis.drawZeroLineEnabled = true
    }
    
    public func setHideLeftAxis(){
        self.leftAxis.enabled = false
    }
}
