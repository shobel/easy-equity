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

    //TODO-SAM: add arrow up/down %change next to forward pe number
    
    private var peDataSets:[ScatterChartDataSet] = []
    private var formatter:PriceChartFormatter = PriceChartFormatter()
    private var earningsDelegate: EarningsViewController!
    
    public func setup(company:Company, delegate: EarningsViewController){
        self.earningsDelegate = delegate
        
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
                if (reversedEarnings.count == 5 && i < reversedEarnings.count - 1) || reversedEarnings.count < 5{
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
                        let compValue = candle.date!.compare(e.getDate()!).rawValue
                        if compValue == 1 || compValue == 0 {
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
            self.earningsDelegate.updatePELegendValues(pe: String(format: "%.2f", Double(peEntries[peEntries.count-1].y)), peFwd: String(format: "%.2f", Double(fwdPe)))
            forwardPeEntries.append(ChartDataEntry(x: Double(reversedEarnings.count), y: fwdPe))
            self.formatter.addXAxisLabel(label)

            let peDataSet = ScatterChartDataSet(entries: peEntries)
            self.configureScatterDataSet(set: peDataSet, color: Constants.blue)
            let forwardPeSet = ScatterChartDataSet(entries: forwardPeEntries)
            self.configureScatterDataSet(set: forwardPeSet, color: Constants.fadedBlue)
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
                let tenPercentRange = (data.yMax - data.yMin)*0.2
                self.leftAxis.axisMaximum = data.yMax + tenPercentRange
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
        set.drawValuesEnabled = true
    }

}
