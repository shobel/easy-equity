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
        self.isUserInteractionEnabled = false
        self.setScaleEnabled(false)
        self.pinchZoomEnabled = false
        self.doubleTapToZoomEnabled = false
        self.autoScaleMinMaxEnabled = true
        
        self.leftAxis.enabled = false
        self.rightAxis.enabled = false
        self.xAxis.enabled = false
        self.noDataText = ""
    }
    
    public func setData(_ quote: Quote){
        var lineEntries:[ChartDataEntry] = []
        var previousLineEntries:[ChartDataEntry] = []
        let data = quote.simplifiedChart
        if data.count == 0 {
            return
        }
        var lastTime:String = ""
        for i in 0..<data.count {
            lineEntries.append(ChartDataEntry(x: Double(i), y: data[i].value))
            lastTime = data[i].datestring!
        }
        
        if data.count < 39 && !Dataholder.isUSMarketOpen {
            let missing = 39 - data.count
            let lastChartEntry = lineEntries.last
            for i in 0..<missing {
                if lastChartEntry != nil {
                    lineEntries.append(ChartDataEntry(x: Double(i+data.count), y: lastChartEntry!.y))
                }
            }
        }
        
        let lineChartDataSet = LineChartDataSet(entries: lineEntries)
        lineChartDataSet.drawCirclesEnabled = false
        lineChartDataSet.drawCircleHoleEnabled = false
        lineChartDataSet.drawValuesEnabled = false
        lineChartDataSet.drawFilledEnabled = false
        lineChartDataSet.setColor(data[data.count - 1].value > quote.previousClose! ? Constants.green : Constants.darkPink)
        
        previousLineEntries.append(ChartDataEntry(x: Double(0), y: quote.previousClose!))
        previousLineEntries.append(ChartDataEntry(x: Double(39), y: quote.previousClose!))
        let previousLineChartDataSet = LineChartDataSet(entries: previousLineEntries)
        previousLineChartDataSet.drawCirclesEnabled = false
        previousLineChartDataSet.drawCircleHoleEnabled = false
        previousLineChartDataSet.drawValuesEnabled = false
        previousLineChartDataSet.drawFilledEnabled = false
        previousLineChartDataSet.setColor(.gray)
        previousLineChartDataSet.lineDashLengths = [1, 4]
        
        DispatchQueue.main.async {
            self.data = LineChartData(dataSets: [previousLineChartDataSet, lineChartDataSet])
            //self.xAxis.axisMaximum = (self.data!.xMax / self.getElapsedFraction(lastTime))
            self.xAxis.axisMaximum = 40
            self.notifyDataSetChanged()
        }
    }
    
    //this code won't work currently because we aren't storing the time in EST minutes anymore in the simplified chart
//    private func getElapsedFraction(_ lastTime:String) -> Double{
//        let firstHour = 9
//        let firstMinute = 30
//        let lastHour = Int(lastTime.split(separator: ":")[0])!
//        let lastMinute = Int(lastTime.split(separator: ":")[1])!
//        let hourDiff = lastHour - firstHour
//        let minDiff = lastMinute - firstMinute
//        let totalMinDiff = hourDiff * 60 + minDiff
//        let elapsedFraction:Double = Double(totalMinDiff)/390.0
//        return elapsedFraction
//    }
}
