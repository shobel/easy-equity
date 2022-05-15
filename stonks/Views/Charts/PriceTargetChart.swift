//
//  PriceTargetChart.swift
//  stonks
//
//  Created by Samuel Hobel on 8/14/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import UIKit
import Charts

class PriceTargetChart: CombinedChartView {

    private var lineChartDataSets:[LineChartDataSet] = []
    private var predictionsDelegate: PredictionsViewController!
    private var company:Company!
    private var allMode:Bool!
    public var animated:Bool = false
    
    public func setup(company:Company, predictionsDelegate: PredictionsViewController, allMode:Bool){
        self.delegate = delegate
        self.predictionsDelegate = predictionsDelegate
        self.company = company
        self.allMode = allMode
        
        self.chartDescription?.enabled = false
        self.legend.enabled = false
        self.dragEnabled = false
        self.setScaleEnabled(false)
        self.pinchZoomEnabled = false
        self.doubleTapToZoomEnabled = false
        self.autoScaleMinMaxEnabled = true
        
        self.leftAxis.labelFont = UIFont(name: "Futura", size: 12)!
        self.leftAxis.labelTextColor = Constants.lightGrey
        self.leftAxis.drawGridLinesEnabled = false
        self.leftAxis.labelPosition = .outsideChart
        self.leftAxis.drawAxisLineEnabled = false
        self.leftAxis.enabled = true
        self.rightAxis.enabled = false
        
        self.xAxis.enabled = true
        self.xAxis.axisMinimum = -0.5
        self.xAxis.drawGridLinesEnabled = false
        self.xAxis.labelPosition = .bottom
        self.xAxis.labelTextColor = .white
        self.xAxis.granularity = 1
        self.xAxis.drawAxisLineEnabled = false

        if (company.dailyData.count > 0){
            self.setChartData()
        } else {
            NetworkManager.getMyRestApi().getNonIntradayChart(symbol: company.symbol, timeframe: .daily) { (candles) in
                self.company.dailyData = candles
                self.setChartData()
            }
        }
    }
      
    private func setChartData(){
        lineChartDataSets = []

        var monthDataEntries:[ChartDataEntry] = []
        let monthOfDailyPrices = Array(self.company.dailyData.suffix(40)) //2months
        for i in 0..<monthOfDailyPrices.count {
            let chartItem = monthOfDailyPrices[i]
            monthDataEntries.append(ChartDataEntry(x: Double(i), y: chartItem.close!))
        }
        let latestPrice = self.company.quote?.latestPrice ?? 0.0
        monthDataEntries.append(ChartDataEntry(x: Double(monthOfDailyPrices.count), y: latestPrice))

        var averagePriceTargetEntries:[ChartDataEntry] = []
        var highPriceTargetEntries:[ChartDataEntry] = []
        var lowPriceTargetEntries:[ChartDataEntry] = []

        var allTipranksExpertsHigh:Double? = nil
        var allTipranksExpertsLow:Double? = nil
        
        var avg = 0.0
        var highTarget:Double = -1.0
        var lowTarget = Double(Int.max)
        if self.company.priceTarget?.currency == "USD" {
            avg = self.company.priceTarget?.priceTargetAverage ?? 0.0
            highTarget = self.company.priceTarget?.priceTargetHigh ?? -1.0
            lowTarget = self.company.priceTarget?.priceTargetLow ?? Double(Int.max)
        }
        var numAnalysts =  self.company.priceTarget?.numberOfAnalysts ?? 0
        if self.allMode {
            if let ptta = self.company.priceTargetTopAnalysts {
                if ptta.expertRatings?.count ?? 0 > 0 {
                    let newAvgPriceTarget = (avg*Double(numAnalysts)) + ((ptta.avgPriceTarget ?? 0.0)*Double(ptta.numAnalysts ?? 0))
                    numAnalysts += ptta.numAnalysts ?? 0
                    avg = newAvgPriceTarget / Double(numAnalysts)
                }
            }
            if let allExperts = self.company.tipranksAllAnalysts {
                if allExperts.count > 0 {
                    var numTipranksAnalystsWithPriceTargets = 0
                    var priceTargetSum = 0.0
                    for rating in allExperts {
                        if let pt = rating.stockRating?.priceTarget {
                            numTipranksAnalystsWithPriceTargets += 1
                            priceTargetSum += pt
                            if allTipranksExpertsHigh == nil || pt > allTipranksExpertsHigh! {
                                allTipranksExpertsHigh = pt
                            }
                            if allTipranksExpertsLow == nil || pt < allTipranksExpertsLow! {
                                allTipranksExpertsLow = pt
                            }
                        }
                    }
                    if numTipranksAnalystsWithPriceTargets > 0 {
                        let ptAvg = priceTargetSum / Double(numTipranksAnalystsWithPriceTargets)
                        let newAvgPriceTarget = (avg*Double(numAnalysts)) + (ptAvg*Double(numTipranksAnalystsWithPriceTargets))
                        numAnalysts += numTipranksAnalystsWithPriceTargets
                        avg = newAvgPriceTarget / Double(numAnalysts)
                    }
                }
            }
        } else if !self.allMode && self.company.priceTargetTopAnalysts != nil {
            avg = self.company.priceTargetTopAnalysts?.avgPriceTarget ?? 0.0
        }
        
        if self.company.priceTargetsOverTime != nil && self.company.priceTargetsOverTime!.count > 0 && avg == 0 {
            let e = self.company.priceTargetsOverTime![self.company.priceTargetsOverTime!.count - 1]
            if e.priceTarget != nil {
                avg = e.priceTarget!
            }
        }
        if avg == 0 {
            return
        }
        
        averagePriceTargetEntries.append(ChartDataEntry(x: Double(monthOfDailyPrices.count), y: latestPrice))
        averagePriceTargetEntries.append(ChartDataEntry(x: Double(monthOfDailyPrices.count * 2), y: avg))
        
        if self.allMode {
            if let ptta = self.company.priceTargetTopAnalysts {
                highTarget = max(highTarget, ptta.highPriceTarget ?? -1.0)
                highTarget = max(highTarget, allTipranksExpertsHigh ?? highTarget)
            }
        } else if !self.allMode && self.company.priceTargetTopAnalysts != nil {
            highTarget = self.company.priceTargetTopAnalysts?.highPriceTarget ?? -1.0
        }
        if highTarget != -1.0 {
            highPriceTargetEntries.append(ChartDataEntry(x: Double(monthOfDailyPrices.count), y: latestPrice))
            highPriceTargetEntries.append(ChartDataEntry(x: Double(monthOfDailyPrices.count * 2), y: highTarget))
            let highPriceTargetDataSet = LineChartDataSet(entries: highPriceTargetEntries)
            self.configureLineDataSet(set: highPriceTargetDataSet, dashed: true, color: Constants.green)
            self.lineChartDataSets.append(highPriceTargetDataSet)
        }
        
        if self.allMode {
            if let ptta = self.company.priceTargetTopAnalysts {
                lowTarget = min(lowTarget, ptta.lowPriceTarget ?? Double(Int.max))
                lowTarget = min(lowTarget, allTipranksExpertsLow ?? lowTarget)
            }
        } else if !self.allMode && self.company.priceTargetTopAnalysts != nil {
            lowTarget = self.company.priceTargetTopAnalysts?.lowPriceTarget ?? Double(Int.max)
        }
        if lowTarget != Double(Int.max) {
            lowPriceTargetEntries.append(ChartDataEntry(x: Double(monthOfDailyPrices.count), y: latestPrice))
            lowPriceTargetEntries.append(ChartDataEntry(x: Double(monthOfDailyPrices.count * 2), y: lowTarget))
            let lowPriceTargetDataSet = LineChartDataSet(entries: lowPriceTargetEntries)
            self.configureLineDataSet(set: lowPriceTargetDataSet, dashed: true, color: Constants.darkPink)
            self.lineChartDataSets.append(lowPriceTargetDataSet)
        }

        let monthDataSet = LineChartDataSet(entries: monthDataEntries)
        let averagePriceTargetDataSet = LineChartDataSet(entries: averagePriceTargetEntries)
        self.configureLineDataSet(set: monthDataSet, dashed: false, color: Constants.lightGrey.withAlphaComponent(0.5))
        self.configureLineDataSet(set: averagePriceTargetDataSet, dashed: true, color: Constants.lightGrey)
        
        self.lineChartDataSets.append(monthDataSet)
        self.lineChartDataSets.append(averagePriceTargetDataSet)

        DispatchQueue.main.async {
            let data = CombinedChartData()
            data.lineData = LineChartData(dataSets: self.lineChartDataSets)
      
            self.xAxis.axisMaximum = data.xMax + 20
            self.data = data
            self.notifyDataSetChanged()
        }
    }
      
    private func configureLineDataSet(set: LineChartDataSet, dashed: Bool, color: UIColor){
        if dashed{
            set.lineDashLengths = [5, 5]
            set.drawCirclesEnabled = true
            set.circleHoleColor = color
            set.setCircleColor(color)
            set.drawValuesEnabled = true
        } else {
            set.drawCirclesEnabled = false
            set.drawValuesEnabled = false
        }
        set.lineWidth = 2.0
        set.circleRadius = 5.0
        set.setColor(color)
        set.highlightEnabled = false
        set.valueFont = UIFont(name: "Futura-Bold", size: 12)!
        set.valueTextColor = color
        set.valueFormatter = self
    }
    
    public func animate(){
        if !animated {
            self.animate(xAxisDuration: 1.0, yAxisDuration: 0.0, easingOption: .linear)
        }
        self.animated = true
    }

}

extension PriceTargetChart: IValueFormatter {
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        if let latestPrice = self.company.quote?.latestPrice {
            let diff = value - latestPrice
            //self.textColor = getColor(diff)
            let formattedValue = NumberFormatter.formatNumberWithPossibleDecimal(value)
            let percentString = NumberFormatter.formatNumberWithPossibleDecimal((diff / latestPrice) * 100.0)
            if diff > 0 {
                return String("\(formattedValue) (+\(percentString)%)")
            } else if diff < 0 {
                return String("\(formattedValue) (\(percentString)%)")
            } else {
                return String("\(formattedValue)")
            }
        }
        return ""
    }
}
