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
    private var formatter:PriceChartFormatter = PriceChartFormatter()
    private var predictionsDelegate: PredictionsViewController!
    private var company:Company!
    
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
        var lastClose = 0.0
        for i in 0..<monthOfDailyPrices.count {
            let chartItem = monthOfDailyPrices[i]
            monthDataEntries.append(ChartDataEntry(x: Double(i), y: chartItem.close!))
            lastClose = chartItem.close!
        }
        
        var averagePriceTargetEntries:[ChartDataEntry] = []
        if self.company.priceTarget != nil {
            averagePriceTargetEntries.append(ChartDataEntry(x: Double(monthOfDailyPrices.count), y: Double(lastClose)))
            averagePriceTargetEntries.append(ChartDataEntry(x: Double(monthOfDailyPrices.count + 10), y: Double((self.company.priceTarget?.priceTargetAverage!)!)))
        }

        let monthDataSet = LineChartDataSet(entries: monthDataEntries)
        let averagePriceTargetDataSet = LineChartDataSet(entries: averagePriceTargetEntries)
        self.configureLineDataSet(set: monthDataSet, dashed: false)
        self.configureLineDataSet(set: averagePriceTargetDataSet, dashed: true)
        
        self.lineChartDataSets.append(monthDataSet)
        self.lineChartDataSets.append(averagePriceTargetDataSet)
              
        DispatchQueue.main.async {
            let data = CombinedChartData()
            data.lineData = LineChartData(dataSets: self.lineChartDataSets)
      
            self.xAxis.axisMaximum = data.xMax + 0.5
            self.data = data
            self.notifyDataSetChanged()
        }
    }
      
    private func configureLineDataSet(set: LineChartDataSet, dashed: Bool){
        if dashed{
            set.lineDashLengths = [5, 5]
        }
        set.setColor(UIColor.lightGray)
        set.drawCirclesEnabled = false
        set.highlightEnabled = false
        set.drawValuesEnabled = false
    }

}
