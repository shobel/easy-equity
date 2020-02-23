//
//  EPSChart.swift
//  stonks
//
//  Created by Samuel Hobel on 2/19/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import UIKit
import Charts

class PEChart: CombinedChartView {

    private var peDataSets:[ScatterChartDataSet] = []
    private var formatter:PriceChartFormatter = PriceChartFormatter()
    
    public func setup(company:Company){
        self.delegate = delegate
        
        self.chartDescription?.enabled = false
        self.legend.enabled = false
        self.dragEnabled = false
        self.setScaleEnabled(false)
        self.pinchZoomEnabled = false
        self.doubleTapToZoomEnabled = false
        self.autoScaleMinMaxEnabled = true
        
        self.leftAxis.labelFont = UIFont(name: "Charter", size: 12)!
        self.leftAxis.labelTextColor = UIColor.gray
        self.leftAxis.drawGridLinesEnabled = false
        self.leftAxis.labelPosition = .outsideChart
        self.leftAxis.drawAxisLineEnabled = false
        self.leftAxis.enabled = true
        self.rightAxis.enabled = false
        
        self.xAxis.enabled = true
        self.xAxis.axisMinimum = -0.5
        self.xAxis.drawGridLinesEnabled = false
        self.xAxis.labelPosition = .bottom
        self.xAxis.valueFormatter = self.formatter
        self.xAxis.granularity = 1
        self.xAxis.drawAxisLineEnabled = false

        self.drawOrder = [DrawOrder.bar.rawValue, DrawOrder.line.rawValue, DrawOrder.scatter.rawValue]
        self.setChartData(company: company)
    }
    
    private func setChartData(company:Company){
        if company.earnings != nil {
            var peEntries:[ChartDataEntry] = []
            var pastEarnings:[Double] = []
            let reversedEarnings = Array(company.earnings!.reversed())
            for i in 0..<reversedEarnings.count{
                let e = reversedEarnings[i]
                if i < reversedEarnings.count - 1{
                    pastEarnings.append(e.yearAgo!)
                }
                self.formatter.addXAxisLabel(e.fiscalPeriod!)
            }
            
            for i in 0...reversedEarnings.count {
                if i < company.earnings!.count {
                    let e = reversedEarnings[i]
                    pastEarnings.append(e.actualEPS!)
                    var sum = 0.0
                    for j in (i+1)..<(i+5) {
                        sum += pastEarnings[j]
                    }
                    var found = false
                    for k in stride(from: company.weeklyData.count-1, to: 0, by: -1) {
                        let candle = company.weeklyData[k]
                        if (CandleUtility.earningsIsInCandleDate(date: candle.date!, prevDate: nil, earnings: [e], timeInterval: Constants.TimeIntervals.one_year) != nil) {
                            peEntries.append(ChartDataEntry(x: Double(i), y: candle.close!/sum))
                            found = true
                            break
                        }
                    }
                    if !found {
                        print("couldnt find candle for \(e.EPSReportDate)")
                    }
                }
            }
            var forwardPeEntries:[ChartDataEntry] = []
            var label = "Future"
            var fwdPe = 0.0
            if let est = company.estimates {
                label = est.fiscalPeriod!
                var sum = 0.0
                for i in stride(from: pastEarnings.count - 1, to: 0, by: -1) {
                    sum += pastEarnings[i]
                }
                sum += est.consensusEPS!
                fwdPe = company.quote!.close! / sum
            }
            if let fpe = company.advancedStats?.forwardPERatio {
                fwdPe = fpe
            }
            forwardPeEntries.append(ChartDataEntry(x: Double(reversedEarnings.count), y: fwdPe))
            self.formatter.addXAxisLabel(label)

            let peDataSet = ScatterChartDataSet(entries: peEntries)
            self.configureScatterDataSet(set: peDataSet, color: Constants.blue)
            let forwardPeSet = ScatterChartDataSet(entries: forwardPeEntries)
            self.configureScatterDataSet(set: forwardPeSet, color: Constants.fadedBlue)
            forwardPeSet.drawValuesEnabled = true
            self.peDataSets.append(peDataSet)
            self.peDataSets.append(forwardPeSet)
            
            DispatchQueue.main.async {
                let data = CombinedChartData()
                data.scatterData = ScatterChartData(dataSets: self.peDataSets)
                //data.lineData = LineChartData(dataSets: self.epsTTM)
                //data.barData = BarChartData(dataSets: self.numEstimates)
                //data.barData.barWidth = 0.1
                //self.rightAxis.axisMaximum = data.barData.yMax * 2
                self.xAxis.axisMaximum = data.xMax + 0.5
                self.data = data
                self.notifyDataSetChanged()
                
            }
            
        }
    }
    
    private func configureScatterDataSet(set: ScatterChartDataSet, color: UIColor){
        set.setScatterShape(.circle)
        set.setColor(color)
        set.scatterShapeSize = CGFloat(20)
        set.highlightEnabled = false
        set.drawValuesEnabled = false
    }
    
    private func configureBarDataSet(set: BarChartDataSet){
        set.axisDependency = .right
        set.setColor(Constants.fadedOrange)
        set.highlightEnabled = false
        set.drawValuesEnabled = false
    }
    
    private func configureLineDataSet(set: LineChartDataSet){
        set.setColor(UIColor.lightGray)
        set.drawCirclesEnabled = false
        set.highlightEnabled = false
        set.drawValuesEnabled = false
    }

}
