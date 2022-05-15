//
//  PriceTargetChart.swift
//  stonks
//
//  Created by Samuel Hobel on 8/14/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import UIKit
import Charts

class PriceTargetsOverTimeChart: CombinedChartView, IAxisValueFormatter {

    private var lineChartDataSets:[LineChartDataSet] = []
    private var company:Company!
    private var allMode:Bool!
    public var animated:Bool = false
    
    private var yearOfDailyPrices:[Candle] = []
    
    public func setup(company:Company, allMode:Bool){
        self.delegate = delegate
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
        self.xAxis.labelTextColor = Constants.lightGrey
        self.xAxis.granularity = 1
        self.xAxis.drawAxisLineEnabled = false
        self.xAxis.valueFormatter = self
//        self.xAxis.labelRotationAngle = CGFloat(20.0)
        
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
        var yearEntries:[ChartDataEntry] = []
        var averagePriceTargetEntries:[ChartDataEntry] = []
        self.yearOfDailyPrices = Array(self.company.dailyData.suffix(260))
        for i in 0..<yearOfDailyPrices.count {
            let chartItem = yearOfDailyPrices[i]
            if allMode {
                if let priceTargetMatch = self.findPriceTargetForChartEntry(self.company.priceTargetsOverTime, dateMatch: chartItem.datetime ?? "") {
                    let chartEntry = ChartDataEntry(x: Double(i), y: priceTargetMatch)
                    averagePriceTargetEntries.append(chartEntry)
                }
            } else {
                if let priceTargetMatch = self.findPriceTargetForChartEntry(self.company.bestPriceTargetsOverTime, dateMatch: chartItem.datetime ?? "") {
                    let chartEntry = ChartDataEntry(x: Double(i), y: priceTargetMatch)
                    averagePriceTargetEntries.append(chartEntry)
                }
            }
            yearEntries.append(ChartDataEntry(x: Double(i), y: chartItem.close!))
        }
        let latestPrice = self.company.quote?.latestPrice ?? 0.0
        yearEntries.append(ChartDataEntry(x: Double(yearOfDailyPrices.count), y: latestPrice))

        let yearDataSet = LineChartDataSet(entries: yearEntries)
        let averagePriceTargetDataSet = LineChartDataSet(entries: averagePriceTargetEntries)
        self.configureLineDataSet(set: yearDataSet, dashed: false, color: Constants.lightGrey.withAlphaComponent(0.5))
        self.configureLineDataSet(set: averagePriceTargetDataSet, dashed: false, color: .orange)
        
        lineChartDataSets = []
        self.lineChartDataSets.append(yearDataSet)
        self.lineChartDataSets.append(averagePriceTargetDataSet)

        DispatchQueue.main.async {
            let data = CombinedChartData()
            data.lineData = LineChartData(dataSets: self.lineChartDataSets)
      
            self.xAxis.axisMaximum = data.xMax + 10
            self.data = data
            self.notifyDataSetChanged()
        }
    }
    
    private func findPriceTargetForChartEntry(_ priceTargetArray:[SimpleTimeAndPrice]?, dateMatch:String) -> Double? {
        if let ptot = priceTargetArray {
            for j in 0..<ptot.count {
                if let d = ptot[j].date {
                    if d.contains("/"){
                        let split = d.split(separator: "/")
                        if split.count == 3 {
                            let year = split[2]
                            var month = split[0]
                            if Int(month) ?? 0 < 10 {
                                month = "0\(month)"
                            }
                            var day = split[1]
                            if Int(day) ?? 0 < 10 {
                                day = "0\(day)"
                            }
                            let formattedDate:String = String("\(year)-\(month)-\(day)")
                            if dateMatch == formattedDate {
                                return ptot[j].priceTarget
                            }
                        }
                    }
                }
            }
        }
        return nil
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
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        if value == 0 || value == 250 {
            if Double(self.yearOfDailyPrices.count) > value {
                return self.yearOfDailyPrices[Int(value)].dateLabel ?? ""
            }
        }
        return ""
    }

}

extension PriceTargetsOverTimeChart: IValueFormatter {
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
