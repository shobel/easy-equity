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
    
    public func setData(_ quote: Quote){
        var lineEntries:[ChartDataEntry] = []
        let data = quote.simplifiedChart!
        var lastTime:String = ""
        for i in 0..<data.count {
            lineEntries.append(ChartDataEntry(x: Double(i), y: data[i].value))
            lastTime = data[i].datestring!
        }
        let lineChartDataSet = LineChartDataSet(entries: lineEntries)
        lineChartDataSet.drawCirclesEnabled = false
        lineChartDataSet.drawCircleHoleEnabled = false
        lineChartDataSet.drawValuesEnabled = false
        lineChartDataSet.drawFilledEnabled = false
        lineChartDataSet.setColor(data[data.count - 1].value > quote.previousClose! ? Constants.green : Constants.darkPink)
        
        DispatchQueue.main.async {
            self.data = LineChartData(dataSet: lineChartDataSet)
            self.xAxis.axisMaximum = (self.data!.xMax / self.getElapsedFraction(lastTime))
            self.notifyDataSetChanged()
        }
    }
    
    private func getElapsedFraction(_ lastTime:String) -> Double{
        let firstHour = 9
        let firstMinute = 30
        let lastHour = Int(lastTime.split(separator: ":")[0])!
        let lastMinute = Int(lastTime.split(separator: ":")[1])!
        let hourDiff = lastHour - firstHour
        let minDiff = lastMinute - firstMinute
        let totalMinDiff = hourDiff * 60 + minDiff
        let elapsedFraction:Double = Double(totalMinDiff)/390.0
        return elapsedFraction
    }
}
