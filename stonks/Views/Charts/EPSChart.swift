//
//  EPSChart.swift
//  stonks
//
//  Created by Samuel Hobel on 2/19/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import UIKit
import Charts

class EPSChart: CombinedChartView {

    private var earningsDataSets:[ScatterChartDataSet] = []
    private var numEstimates:[BarChartDataSet] = []
    private var epsTTM:[LineChartDataSet] = []
    private var formatter:PriceChartFormatter = PriceChartFormatter()
    private var earningsDelegate: EarningsViewController!

    public func setup(company:Company, earningsDelegate: EarningsViewController){
        self.delegate = delegate
        self.earningsDelegate = earningsDelegate
        
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
            var actualEarningsEntries:[ChartDataEntry] = []
            var expectedEarningsEntries:[ChartDataEntry] = []
            var estimatesEntries:[BarChartDataEntry] = []
            var epsTTMEntries:[ChartDataEntry] = []
            var pastEarnings:[Double] = []
            let reversedEarnings = Array(company.earnings!.reversed())
            for i in 0..<reversedEarnings.count {
                let e = reversedEarnings[i]
                actualEarningsEntries.append(ChartDataEntry(x: Double(i), y: e.actualEPS!))
                expectedEarningsEntries.append(ChartDataEntry(x: Double(i), y: e.consensusEPS!))
                estimatesEntries.append(BarChartDataEntry(x: Double(i), y: Double(e.numberOfEstimates!)))
                pastEarnings.append(e.yearAgo!)
                self.formatter.addXAxisLabel(e.fiscalPeriod!)
            }
            for i in 0...reversedEarnings.count {
                if i < company.earnings!.count {
                    let e = company.earnings![i]
                    pastEarnings.append(e.actualEPS!)
                }

                var sum = 0.0
                for j in i..<(i+4) {
                    sum += pastEarnings[j]
                }
                let ttm = sum / 4
                epsTTMEntries.append(ChartDataEntry(x: Double(i), y: ttm))
            }
            
            var fwdLabelValue = "-"
            var fwdEpsDate = ""
            if let est = company.estimates{
                //only add forward EPS to the chart if we dont already have it, meaning it's lagging behind from a passed earnings reports
                var isForward = true
                for i in 0..<reversedEarnings.count {
                    if est.fiscalPeriod == reversedEarnings[i].fiscalPeriod {
                        isForward = false
                    }
                }
                if isForward {
                    if est.consensusEPS != nil && est.fiscalPeriod != nil{
                        fwdLabelValue = String(est.consensusEPS!)
                        fwdEpsDate = est.fiscalPeriod!
                        expectedEarningsEntries.append(ChartDataEntry(x: Double(company.earnings!.count), y: est.consensusEPS!))
                        estimatesEntries.append(BarChartDataEntry(x: Double(company.earnings!.count), y: Double(est.numberOfEstimates ?? 0)))
                        self.formatter.addXAxisLabel(est.fiscalPeriod!)
                    }
                }
            }
            
            var actualEpsLabel = "-"
            var epsDate = ""
            if actualEarningsEntries.count > 0 && self.formatter.xAxisLabels.count >= actualEarningsEntries.count{
                actualEpsLabel = String(format: "%.2f", actualEarningsEntries[actualEarningsEntries.count - 1].y)
                epsDate = self.formatter.xAxisLabels[actualEarningsEntries.count - 1]
                //reversedEarnings[reversedEarnings.count - 1].EPSReportDate!
            }
            var avgLabelValue = "-"
            if epsTTMEntries.count > 0{
                avgLabelValue = String(format: "%.2f", epsTTMEntries[epsTTMEntries.count - 1].y)
            }
            earningsDelegate.updateEPSLegendValues(eps: actualEpsLabel, epsDate: epsDate, epsFwd: fwdLabelValue, epsFwdDate: fwdEpsDate, avg: avgLabelValue)
            
            let actualEarningsDataSet = ScatterChartDataSet(entries: actualEarningsEntries)
            self.configureScatterDataSet(set: actualEarningsDataSet, color: Constants.darkPink)
            let expectedEarningsDataSet = ScatterChartDataSet(entries: expectedEarningsEntries)
            self.configureScatterDataSet(set: expectedEarningsDataSet, color: Constants.fadedDarkPink)
            let estimatesDataSet = BarChartDataSet(entries: estimatesEntries)
            self.configureBarDataSet(set: estimatesDataSet)
            let epsTTMDataSet = LineChartDataSet(entries: epsTTMEntries)
            self.configureLineDataSet(set: epsTTMDataSet)
            
            self.earningsDataSets.append(expectedEarningsDataSet)
            self.earningsDataSets.append(actualEarningsDataSet)
            self.numEstimates.append(estimatesDataSet)
            self.epsTTM.append(epsTTMDataSet)
            
            DispatchQueue.main.async {
                let data = CombinedChartData()
                data.scatterData = ScatterChartData(dataSets: self.earningsDataSets)
                data.lineData = LineChartData(dataSets: self.epsTTM)
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
