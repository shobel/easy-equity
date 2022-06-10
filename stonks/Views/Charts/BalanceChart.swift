//
//  PriceChartPreviewView.swift
//  stonks
//
//  Created by Samuel Hobel on 8/22/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import UIKit
import Charts

class BalanceChart: LineChartView {
   
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
        self.leftAxis.drawAxisLineEnabled = false
        self.leftAxis.labelPosition = .insideChart
        self.leftAxis.labelCount = 2
        self.leftAxis.drawGridLinesEnabled = false
        self.leftAxis.valueFormatter = BigNumberAxisFormatter()
        self.rightAxis.enabled = false
        self.xAxis.enabled = false
        self.noDataText = "No data"
    }
    
    public func config(enableLeftAxis:Bool){
        self.leftAxis.enabled = enableLeftAxis
    }
    
    public func setLabelPosition(outside:Bool) {
        if outside {
            self.leftAxis.labelPosition = .outsideChart
        } else {
            self.leftAxis.labelPosition = .insideChart
        }
    }
    
    public func setData(_ data: [DateAndBalance]){
        self.setup()
        
        var datasets:[LineChartDataSet] = []
        var lineEntries:[ChartDataEntry] = []

        for i in 0..<data.count {
            lineEntries.append(ChartDataEntry(x: Double(i), y: data[i].balance ?? 0.0))
        }
            
        let lineChartDataSet = LineChartDataSet(entries: lineEntries)
        lineChartDataSet.drawCirclesEnabled = true
        lineChartDataSet.drawCircleHoleEnabled = false
        lineChartDataSet.drawValuesEnabled = false
        lineChartDataSet.drawFilledEnabled = false
        lineChartDataSet.circleRadius = 5.0
        lineChartDataSet.circleColors = [Constants.lightPurple]
        lineChartDataSet.setColor(Constants.lightPurple)
        if lineChartDataSet.count > 0 {
            datasets.append(lineChartDataSet)
        }
        
        DispatchQueue.main.async {
            if datasets.count > 0 {
                self.data = LineChartData(dataSets: datasets)
            }
            self.notifyDataSetChanged()
        }
    }
    
    public func setDrawZeroLine(){
        //self.leftAxis.drawZeroLineEnabled = true
    }
    
    public func setHideLeftAxis(){
        self.leftAxis.enabled = false
    }
}
