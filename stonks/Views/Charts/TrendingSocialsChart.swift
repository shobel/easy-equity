//
//  TrendingSocialsChart.swift
//  stonks
//
//  Created by Samuel Hobel on 5/21/22.
//  Copyright © 2022 Samuel Hobel. All rights reserved.
//

import UIKit
import Charts

class TrendingSocialsChart: BarChartView {
    
    private var xLabels:[String] = []

    public func setup(){
               
        self.chartDescription?.enabled = false
        self.legend.enabled = false
        self.dragEnabled = false
        self.setScaleEnabled(false)
        self.pinchZoomEnabled = false
        self.doubleTapToZoomEnabled = false
//        self.autoScaleMinMaxEnabled = true
            
        self.leftAxis.drawGridLinesEnabled = false
        self.leftAxis.drawAxisLineEnabled = true
        self.leftAxis.enabled = false
        self.leftAxis.valueFormatter = BigNumberAxisFormatter()
        self.leftAxis.drawZeroLineEnabled = false
        self.leftAxis.labelTextColor = Constants.lightGrey
        self.leftAxis.axisMinimum = 0.0
        self.rightAxis.enabled = false
      
        self.xAxis.enabled = true
        self.xAxis.drawGridLinesEnabled = false
        self.xAxis.labelPosition = .bottom
        self.xAxis.labelCount = 10
        self.xAxis.granularity = 1
        self.xAxis.axisMinimum = -0.2

        self.xAxis.centerAxisLabelsEnabled = true
//        self.xAxis.forceLabelsEnabled = true
//        self.xAxis.granularityEnabled = true
        self.xAxis.drawAxisLineEnabled = false
        self.xAxis.wordWrapEnabled = false
        self.xAxis.xOffset = 10.0
//        self.xAxis.valueFormatter = self
        self.xAxis.labelRotationAngle = 45.0
        self.xAxis.labelTextColor = Constants.lightGrey
        self.noDataText = "unavailable"
    }
             
    public func setChartData(data:[SocialSentimentFMP]){
        var d = data
        d.sort { a, b in
            return a.twitterSentiment ?? 0.0 > b.twitterSentiment ?? 0.0
        }
        var entries:[BarChartDataEntry] = []
        self.xLabels = []

        for i in 0..<d.count {
            let entry = d[i]
            self.xLabels.append(entry.symbol ?? "")
            entries.append(BarChartDataEntry(x: Double(i) + 0.4, y: Double(entry.twitterSentiment ?? 0.0)))
        }
        self.xAxis.valueFormatter = IndexAxisValueFormatter(values: self.xLabels)
        let entryset = BarChartDataSet(entries: entries)
        self.configureDataSet(dataset: entryset, label: "trending", color: Constants.green)

        DispatchQueue.main.async {
            let data = BarChartData()
            data.addDataSet(entryset)
            let barWidth = 0.5
            data.barWidth = barWidth
//            self.xAxis.granularity = self.xAxis.axisMaximum / Double(entryset.count)

            self.data = data
            self.notifyDataSetChanged()
        }
    }
    
    func configureDataSet(dataset: BarChartDataSet, label:String, color: UIColor) {
        dataset.valueTextColor = Constants.lightGrey
        dataset.drawValuesEnabled = false
        dataset.highlightEnabled = false
        dataset.valueFont = dataset.valueFont.withSize(11.0)
        dataset.label = label
        dataset.setColor(color)
    }
}

//extension TrendingSocialsChart: IAxisValueFormatter {
//    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
//        let count = self.xLabels.count
//        guard let axis = axis, count > 0 else {
//            return ""
//        }
////        return String(value)
//        let factor = axis.axisMaximum / Double(count)
//        let index = Int((value / factor).rounded())
//        if index >= 0 && index < count {
//            return self.xLabels[index]
//        }
//        return ""
//////        return xLabels[Int(value) % xLabels.count]
//    }
//}
