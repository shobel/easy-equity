//
//  RatingsChart.swift
//  stonks
//
//  Created by Samuel Hobel on 8/15/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import UIKit
import Charts

class RatingsChart: BarChartView {

    private var predictionsDelegate: PredictionsViewController!
    private var company:Company!
    private var xlabels = ["Strong Buy", "Buy", "Hold", "Sell", "Strong Sell"]
    public var animated:Bool = false
       
    public func setup(company:Company, predictionsDelegate: PredictionsViewController){
        self.delegate = delegate
        self.predictionsDelegate = predictionsDelegate
        self.company = company
           
        self.chartDescription?.enabled = false
        self.legend.enabled = false
        self.dragEnabled = false
        self.setScaleEnabled(false)
        self.pinchZoomEnabled = false
        self.doubleTapToZoomEnabled = false
        self.autoScaleMinMaxEnabled = true
        
        self.leftAxis.labelFont = UIFont(name: "Charter", size: 10)!
        self.leftAxis.labelTextColor = UIColor.gray
        self.leftAxis.drawGridLinesEnabled = false
        self.leftAxis.labelPosition = .outsideChart
        self.leftAxis.drawAxisLineEnabled = false
        self.leftAxis.enabled = false
        self.leftAxis.axisMinimum = 0.0
        self.rightAxis.enabled = false
                
        self.xAxis.valueFormatter = self
        self.xAxis.enabled = true
        self.xAxis.axisMinimum = -0.5
        self.xAxis.drawGridLinesEnabled = false
        self.xAxis.labelPosition = .bottom
        self.xAxis.granularity = 1
        self.xAxis.drawAxisLineEnabled = true
        self.xAxis.wordWrapEnabled = true
        
        self.drawBarShadowEnabled = true
        self.extraTopOffset = 10 //isnt doing anything
        self.extraBottomOffset = 20
        self.setChartData()

    }
         
    private func setChartData(){
        if let r = self.company.recommendations {
            let buy = 12 //r.ratingBuy!
            let overweight = 14 // r.ratingOverweight!
            let hold = 10 //r.ratingHold!
            let underweight =  9 //r.ratingUnderweight!
            let sell = 7 //r.ratingSell!
            let overall = r.ratingScaleMark!
            
            var barChartEntries:[BarChartDataEntry] = []
            barChartEntries.append(BarChartDataEntry(x: 0, y: Double(buy)))
            barChartEntries.append(BarChartDataEntry(x: 1, y: Double(overweight)))
            barChartEntries.append(BarChartDataEntry(x: 2, y: Double(hold)))
            barChartEntries.append(BarChartDataEntry(x: 3, y: Double(underweight)))
            barChartEntries.append(BarChartDataEntry(x: 4, y: Double(sell)))
            let set = BarChartDataSet(entries: barChartEntries)
            
            set.colors = [
                UIColor(red: 70.0/255.0, green: 180.0/255.0, blue: 88.0/255.0, alpha: 1.0),
                UIColor(red: 164.0/255.0, green: 217.0/255.0, blue: 51.0/255.0, alpha: 1.0),
                UIColor(red: 206.0/255.0, green: 194.0/255.0, blue: 46.0/255.0, alpha: 1.0),
                UIColor(red: 238.0/255.0, green: 143.0/255.0, blue: 29.0/255.0, alpha: 1.0),
                UIColor(red: 217.0/255.0, green: 58.0/255.0, blue: 51.0/255.0, alpha: 1.0)
            ]

            set.barShadowColor = Constants.veryLightGrey
            set.valueTextColor = Constants.darkGrey
            set.drawValuesEnabled = true
            set.highlightEnabled = false
            set.valueFormatter = self
            set.valueFont = UIFont(name: "Charter", size: 10)!
            
            DispatchQueue.main.async {
                let data = BarChartData(dataSet: set)
                data.barWidth = 0.4
                self.data = data
                self.notifyDataSetChanged()
            }
        }
    }
    
    public func animate(){
        if !animated {
            self.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .easeOutExpo)
        }
        self.animated = true
    }
}

extension RatingsChart: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return xlabels[Int(value) % xlabels.count]
    }
}

extension RatingsChart: IValueFormatter {
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        return String(Int(value.rounded()))
    }

}
