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
        self.xAxis.labelTextColor = .clear
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
        var monthDataEntries:[ChartDataEntry] = []
        let monthOfDailyPrices = Array(self.company.dailyData.suffix(20))
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
        
        if self.company.priceTarget != nil {
            var avg = (self.company.priceTarget?.priceTargetAverage!)!
            var numAnalysts =  self.company.priceTarget?.numberOfAnalysts ?? 0
            if self.allMode {
                if let ptta = self.company.priceTargetTopAnalysts {
                    if ptta.expertRatings?.count ?? 0 > 0 {
                        let newAvgPriceTarget = (avg*Double((self.company.priceTarget?.numberOfAnalysts)!)) + (ptta.avgPriceTarget!*Double(ptta.numAnalysts!))
                        numAnalysts += ptta.numAnalysts!
                        avg = newAvgPriceTarget / Double(numAnalysts)
                    }
                }
                if let allExperts = self.company.tipranksAllAnalysts {
                    if allExperts.count > 0 {
                        var numTipranksAnalystsWithPriceTargets = 0
                        var priceTargetSum = 0.0
                        for var rating in allExperts {
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
                        let ptAvg = priceTargetSum / Double(numTipranksAnalystsWithPriceTargets)
                        let newAvgPriceTarget = (avg*Double(numAnalysts)) + (ptAvg*Double(numTipranksAnalystsWithPriceTargets))
                        numAnalysts += numTipranksAnalystsWithPriceTargets
                        avg = newAvgPriceTarget / Double(numAnalysts)
                    }
                }

            } else if !self.allMode && self.company.priceTargetTopAnalysts != nil {
                avg = self.company.priceTargetTopAnalysts!.avgPriceTarget!
            }
            averagePriceTargetEntries.append(ChartDataEntry(x: Double(monthOfDailyPrices.count), y: latestPrice))
            averagePriceTargetEntries.append(ChartDataEntry(x: Double(monthOfDailyPrices.count + 20), y: avg))
            
            var highTarget = self.company.priceTarget!.priceTargetHigh!
            if self.allMode {
                if let ptta = self.company.priceTargetTopAnalysts {
                    highTarget = max(highTarget, ptta.highPriceTarget!)
                    highTarget = max(highTarget, allTipranksExpertsHigh ?? highTarget)
                }
            } else if !self.allMode && self.company.priceTargetTopAnalysts != nil {
                highTarget = self.company.priceTargetTopAnalysts!.highPriceTarget!
            }
            highPriceTargetEntries.append(ChartDataEntry(x: Double(monthOfDailyPrices.count), y: latestPrice))
            highPriceTargetEntries.append(ChartDataEntry(x: Double(monthOfDailyPrices.count + 20), y: highTarget))
            
            var lowTarget = self.company.priceTarget!.priceTargetLow!
            if self.allMode {
                if let ptta = self.company.priceTargetTopAnalysts {
                    lowTarget = min(lowTarget, ptta.lowPriceTarget!)
                    lowTarget = min(lowTarget, allTipranksExpertsLow ?? lowTarget)
                }
            } else if !self.allMode && self.company.priceTargetTopAnalysts != nil {
                lowTarget = self.company.priceTargetTopAnalysts!.lowPriceTarget!
            }
            lowPriceTargetEntries.append(ChartDataEntry(x: Double(monthOfDailyPrices.count), y: latestPrice))
            lowPriceTargetEntries.append(ChartDataEntry(x: Double(monthOfDailyPrices.count + 20), y: lowTarget))
        }

        let monthDataSet = LineChartDataSet(entries: monthDataEntries)
        let averagePriceTargetDataSet = LineChartDataSet(entries: averagePriceTargetEntries)
        let highPriceTargetDataSet = LineChartDataSet(entries: highPriceTargetEntries)
        let lowPriceTargetDataSet = LineChartDataSet(entries: lowPriceTargetEntries)
        self.configureLineDataSet(set: monthDataSet, dashed: false, color: .gray)
        self.configureLineDataSet(set: averagePriceTargetDataSet, dashed: true, color: .gray)
        self.configureLineDataSet(set: highPriceTargetDataSet, dashed: true, color: Constants.green)
        self.configureLineDataSet(set: lowPriceTargetDataSet, dashed: true, color: Constants.darkPink)
        
        lineChartDataSets = []
        self.lineChartDataSets.append(monthDataSet)
        self.lineChartDataSets.append(highPriceTargetDataSet)
        self.lineChartDataSets.append(lowPriceTargetDataSet)
        self.lineChartDataSets.append(averagePriceTargetDataSet)

        DispatchQueue.main.async {
            let data = CombinedChartData()
            data.lineData = LineChartData(dataSets: self.lineChartDataSets)
      
            self.xAxis.axisMaximum = data.xMax + 10
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
        //return NumberFormatter.formatNumberWithPossibleDecimal(value)
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
