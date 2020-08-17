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

        if self.company.priceTarget != nil {
            averagePriceTargetEntries.append(ChartDataEntry(x: Double(monthOfDailyPrices.count), y: latestPrice))
            averagePriceTargetEntries.append(ChartDataEntry(x: Double(monthOfDailyPrices.count + 20), y: Double((self.company.priceTarget?.priceTargetAverage!)!)))
            highPriceTargetEntries.append(ChartDataEntry(x: Double(monthOfDailyPrices.count), y: latestPrice))
            highPriceTargetEntries.append(ChartDataEntry(x: Double(monthOfDailyPrices.count + 20), y: Double((self.company.priceTarget?.priceTargetHigh!)!)))
            lowPriceTargetEntries.append(ChartDataEntry(x: Double(monthOfDailyPrices.count), y: latestPrice))
            lowPriceTargetEntries.append(ChartDataEntry(x: Double(monthOfDailyPrices.count + 20), y: Double((self.company.priceTarget?.priceTargetLow!)!)))
        }

        let monthDataSet = LineChartDataSet(entries: monthDataEntries)
        let averagePriceTargetDataSet = LineChartDataSet(entries: averagePriceTargetEntries)
        let highPriceTargetDataSet = LineChartDataSet(entries: highPriceTargetEntries)
        let lowPriceTargetDataSet = LineChartDataSet(entries: lowPriceTargetEntries)
        self.configureLineDataSet(set: monthDataSet, dashed: false, color: .gray)
        self.configureLineDataSet(set: averagePriceTargetDataSet, dashed: true, color: .gray)
        self.configureLineDataSet(set: highPriceTargetDataSet, dashed: true, color: Constants.green)
        self.configureLineDataSet(set: lowPriceTargetDataSet, dashed: true, color: Constants.darkPink)
        
        self.lineChartDataSets.append(monthDataSet)
        self.lineChartDataSets.append(highPriceTargetDataSet)
        self.lineChartDataSets.append(lowPriceTargetDataSet)
        self.lineChartDataSets.append(averagePriceTargetDataSet)

        DispatchQueue.main.async {
            let data = CombinedChartData()
            data.lineData = LineChartData(dataSets: self.lineChartDataSets)
      
            self.xAxis.axisMaximum = data.xMax + 5
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
        set.valueTextColor = .darkGray
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
        return NumberFormatter.formatNumberWithPossibleDecimal(value)
    }
}
