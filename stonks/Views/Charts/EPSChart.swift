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
    private var formatter:PriceChartFormatter = PriceChartFormatter()
    private var parentDelegate: FinancialsViewController!

    public func setup(company:Company, parentDelegate: FinancialsViewController){
        self.delegate = delegate
        self.parentDelegate = parentDelegate
        
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
        self.xAxis.labelTextColor = .black

        self.drawOrder = [DrawOrder.bar.rawValue, DrawOrder.line.rawValue, DrawOrder.scatter.rawValue]
        self.setChartData(company: company)
    }
    
    private func setChartData(company:Company){
        if company.earnings != nil {
            var actualEarningsEntries:[ChartDataEntry] = []
            var expectedEarningsEntries:[ChartDataEntry] = []
            let reversedEarnings = Array(Array(company.earnings!.reversed()).suffix(5))
            var fwdLabelValue = "-"
            var fwdEpsDate = ""
            var actualEpsLabel = "-"
            var epsDate = ""
            for i in 0..<reversedEarnings.count {
                let e = reversedEarnings[i]
                if e.actualEPS != nil && e.actualEPS != 0.0 {
                    actualEarningsEntries.append(ChartDataEntry(x: Double(i), y: e.actualEPS!))
                    actualEpsLabel = String(format: "%.2f", e.actualEPS!)
                    epsDate = e.EPSReportDate!
                }
                if e.consensusEPS != nil {
                    expectedEarningsEntries.append(ChartDataEntry(x: Double(i), y: e.consensusEPS!))
                    fwdLabelValue = String(format: "%.2f", e.consensusEPS!)
                    fwdEpsDate = e.EPSReportDate!
                }
                let year = (e.EPSReportDate?.components(separatedBy: "-")[0])!
                let month = (e.EPSReportDate?.components(separatedBy: "-")[1])!
                self.formatter.addXAxisLabel(year + "-" + month)
            }
            parentDelegate.updateEPSLegendValues(eps: actualEpsLabel, epsDate: epsDate, epsFwd: fwdLabelValue, epsFwdDate: fwdEpsDate)
            
            let actualEarningsDataSet = ScatterChartDataSet(entries: actualEarningsEntries)
            self.configureScatterDataSet(set: actualEarningsDataSet, color: Constants.darkPink)
            let expectedEarningsDataSet = ScatterChartDataSet(entries: expectedEarningsEntries)
            self.configureScatterDataSet(set: expectedEarningsDataSet, color: Constants.fadedDarkPink)
            
            self.earningsDataSets.append(expectedEarningsDataSet)
            self.earningsDataSets.append(actualEarningsDataSet)
            
            DispatchQueue.main.async {
                let data = CombinedChartData()
                data.scatterData = ScatterChartData(dataSets: self.earningsDataSets)
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
