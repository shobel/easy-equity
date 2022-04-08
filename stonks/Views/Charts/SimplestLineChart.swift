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
    
    public func setData(_ data: [[Double]], colors:[UIColor]){
        self.setup()
        
        var datasets:[LineChartDataSet] = []
        
        for i in 0..<data.count {
            var lineEntries:[ChartDataEntry] = []
            for j in 0..<data[i].count {
                lineEntries.append(ChartDataEntry(x: Double(j), y: data[i][j]))
            }
            let lineChartDataSet = LineChartDataSet(entries: lineEntries)
            lineChartDataSet.drawCirclesEnabled = false
            lineChartDataSet.drawCircleHoleEnabled = false
            lineChartDataSet.drawValuesEnabled = false
            lineChartDataSet.drawFilledEnabled = false
            
            if colors.count > i {
                lineChartDataSet.setColor(colors[i])
            } else {
                lineChartDataSet.setColor(Constants.blue)
            }
            datasets.append(lineChartDataSet)
        }
        
        DispatchQueue.main.async {
            self.data = LineChartData(dataSets: datasets)
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
