//
//  ScoreSnowflakeChart.swift
//  stonks
//
//  Created by Samuel Hobel on 11/1/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import UIKit
import Charts

class ScoreSnowflakeChart: RadarChartView {
    
    public func setup(scores:[Double]){
        self.legend.enabled = false
        self.rotationEnabled = false
        self.highlightPerTapEnabled = false
        self.isUserInteractionEnabled = false
        self.noDataText = ""

        self.yAxis.drawLabelsEnabled = false
        self.yAxis.axisMaximum = 80.0
        self.yAxis.axisMinimum = 0.0
        self.yAxis.yOffset = 0
        self.yAxis.xOffset = 0
        
        self.xAxis.drawGridLinesEnabled = false
        self.xAxis.drawAxisLineEnabled = false
        self.xAxis.drawLabelsEnabled = false
        self.xAxis.labelFont = .systemFont(ofSize: 8, weight: .light)
        self.xAxis.xOffset = 0
        self.xAxis.yOffset = 0
        //let chartFormatter = RadarChartFormatter(labels: self.categories)
        //self.xAxis.valueFormatter = chartFormatter
        
        self.webColor = .black
        self.innerWebColor = Constants.lightGrey
        
        var entries:[RadarChartDataEntry] = []
        for score in scores {
            entries.append(RadarChartDataEntry(value: score))
        }

        let set = RadarChartDataSet(entries: entries)
        set.fillColor = Constants.lightPurple
        set.setColor(Constants.lightPurple)
        set.drawFilledEnabled = true
        set.fillAlpha = 0.5
        set.lineWidth = 2
        
        let data:RadarChartData = RadarChartData(dataSet: set)
        data.setDrawValues(false)
        self.data = data
        
        self.data?.notifyDataChanged()
        self.notifyDataSetChanged()
        self.setNeedsDisplay()
        
    }
    
}

private class RadarChartFormatter: NSObject, IAxisValueFormatter {
    
    var labels: [String] = []
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        if Int(value) < labels.count {
            return labels[Int(value)]
        }else{
            return String("")
        }
    }
    
    init(labels: [String]) {
        super.init()
        self.labels = labels
    }
}
