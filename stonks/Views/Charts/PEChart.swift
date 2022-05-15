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
    private var earningsDelegate: FinancialsViewController!
    
    public func setup(company:Company, delegate: FinancialsViewController){
        self.earningsDelegate = delegate
        
        self.chartDescription?.enabled = false
        self.legend.enabled = false
        self.dragEnabled = false
        self.setScaleEnabled(false)
        self.pinchZoomEnabled = false
        self.doubleTapToZoomEnabled = false
        self.autoScaleMinMaxEnabled = true
        
        self.leftAxis.labelFont = UIFont(name: "Charter", size: 12)!
        self.leftAxis.labelTextColor = Constants.lightGrey
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
        self.xAxis.labelTextColor = Constants.lightGrey
        
        self.drawOrder = [DrawOrder.bar.rawValue, DrawOrder.line.rawValue, DrawOrder.scatter.rawValue]
        self.setChartData(company: company)
    }
    
    private func setChartData(company:Company){
        var peEntries:[ChartDataEntry] = []
        var forwardPeEntries:[ChartDataEntry] = []
        var fwdPe = 0.0
        
        let today = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        let formattedToday = format.string(from: today)
        
        if let earnings = company.earnings, company.dailyData.count > 0 {
            let reversedEarnings = Array(Array(earnings.reversed()).suffix(5))
            for i in 0..<reversedEarnings.count {
                var epsSum = 0.0
                for j in (i-3)...i {
                    if j < 0 && i+1 < reversedEarnings.count{
                        epsSum += reversedEarnings[i+1].yearAgo ?? 0.0
                    } else if j >= 0 {
                        epsSum += reversedEarnings[j].actualEPS ?? 0.0
                    }
                }
                let e = reversedEarnings[i]
                if NumberFormatter.convertStringDateToInt(date: e.EPSReportDate!) > NumberFormatter.convertStringDateToInt(date: formattedToday){
                    epsSum += e.consensusEPS!
                    forwardPeEntries.append(ChartDataEntry(x: Double(i), y: (company.quote?.latestPrice ?? 0.0) / epsSum))
                    fwdPe = (company.quote?.latestPrice ?? 0.0) / epsSum
                    let year = (e.EPSReportDate?.components(separatedBy: "-")[0])!
                    let month = (e.EPSReportDate?.components(separatedBy: "-")[1])!
                    self.formatter.addXAxisLabel(year + "-" + month)
                } else {
                    let reversedDaily = Array(company.dailyData.reversed())
                    for j in 0..<reversedDaily.count{
                        let dailyEntry = reversedDaily[j]
                        if e.EPSReportDate == dailyEntry.datetime {
                            let price = dailyEntry.close
                            if e.actualEPS != 0.0 && epsSum != 0.0 {
                                peEntries.append(ChartDataEntry(x: Double(i), y: price! / epsSum))
                            }
                            let year = (e.EPSReportDate?.components(separatedBy: "-")[0])!
                            let month = (e.EPSReportDate?.components(separatedBy: "-")[1])!
                            self.formatter.addXAxisLabel(year + "-" + month)
                            break
                        }
                    }
                }
            }

        }
        var actualPe = 0.0
        if let pe = company.quote?.peRatio {
            actualPe = pe
        }
        self.earningsDelegate.updatePELegendValues(pe: String(format: "%.2f", Double(actualPe)), peFwd: String(format: "%.2f", Double(fwdPe)))

        let peDataSet = ScatterChartDataSet(entries: peEntries.suffix(5))
        self.configureScatterDataSet(set: peDataSet, color: Constants.blue)
        let forwardPeSet = ScatterChartDataSet(entries: forwardPeEntries)
        self.configureScatterDataSet(set: forwardPeSet, color: Constants.fadedBlue)
        if peDataSet.count > 0 {
            self.peDataSets.append(peDataSet)
        }
        if forwardPeSet.count > 0 {
            self.peDataSets.append(forwardPeSet)
        }
            
        DispatchQueue.main.async {
            if (self.peDataSets.count > 0){
                let data = CombinedChartData()
                data.scatterData = ScatterChartData(dataSets: self.peDataSets)
                self.xAxis.axisMaximum = data.xMax + 0.5
                let percentRange = (data.yMax - data.yMin)*0.2
                self.leftAxis.axisMaximum = data.yMax + percentRange
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

}
