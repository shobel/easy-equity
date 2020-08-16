//
//  CustomCandleChartView.swift
//  stonks
//
//  Created by Samuel Hobel on 9/14/19.
//  Copyright © 2019 Samuel Hobel. All rights reserved.
//

import UIKit
import Charts

class CustomCombinedChartView: CombinedChartView {
    
    private var stockDetailsDelegate: StockDetailsVC?
    private var priceChartFormatter = PriceChartFormatter()
    private var volumeChartFormatter:VolumeChartFormatter!
    
    private var myCandleData:[Candle]?
    private var myCandleDataTenMin:[Candle]?
    
    private var candleChartData:CandleChartData = CandleChartData()
    private var candleChartDataTenMin:CandleChartData = CandleChartData()
    private var lineChartData:LineChartDataSet = LineChartDataSet()
    private var volumeChartData:BarChartData = BarChartData()
    private var volumeChartDataTenMin:BarChartData = BarChartData()
    private var earningsData:ScatterChartData = ScatterChartData()
    private var sma20:LineChartDataSet = LineChartDataSet()
    private var sma50:LineChartDataSet = LineChartDataSet()
    private var sma100:LineChartDataSet = LineChartDataSet()
    private var sma200:LineChartDataSet = LineChartDataSet()

    private var dayEntryCount = 391
    private var previousCloseValue = 0.0
    private var firstLineValue = 0.0
    private var lastLineValue = 0.0
    private var animated:Bool = false
    
    public func setup(delegate: StockDetailsVC){
        self.delegate = delegate
        self.stockDetailsDelegate = delegate
        
        self.chartDescription?.enabled = false
        self.legend.enabled = false
        self.dragEnabled = true
        self.setScaleEnabled(false)
        self.pinchZoomEnabled = false
        self.doubleTapToZoomEnabled = false
        self.autoScaleMinMaxEnabled = true
        self.maxVisibleCount = 500
        
        self.leftAxis.labelFont = UIFont(name: "Charter", size: 12)!
        self.leftAxis.labelTextColor = UIColor.black
        self.leftAxis.drawGridLinesEnabled = false
        self.leftAxis.labelPosition = .insideChart
        self.leftAxis.drawAxisLineEnabled = false
//        self.leftAxis.labelCount = 2
        self.leftAxis.yOffset = -5
        self.leftAxis.forceLabelsEnabled = true
        
        let numFormatter = PriceChartPriceFormatter()
        self.leftAxis.valueFormatter = numFormatter
        self.leftAxis.enabled = true
        self.rightAxis.enabled = false
        self.xAxis.enabled = false
        self.xAxis.axisMinimum = -1.5
        
        self.drawOrder = [DrawOrder.scatter.rawValue, DrawOrder.bar.rawValue, DrawOrder.line.rawValue, DrawOrder.candle.rawValue]
    }
    
    public func hideAxisLabels(hideEarnings: Bool){
        self.leftAxis.drawLabelsEnabled = false
    }
    public func showAxisLabels(showEarnings: Bool){
        self.leftAxis.drawLabelsEnabled = true
    }
    
    public func getChartData(candleMode:Bool) -> [Candle]{
        if self.stockDetailsDelegate!.timeInterval == Constants.TimeIntervals.day && candleMode {
            return self.myCandleDataTenMin!
        }
        return self.myCandleData!
    }
    
    public func setChartData(chartData:[Candle]){
        if self.stockDetailsDelegate?.timeInterval == Constants.TimeIntervals.day {
            self.myCandleDataTenMin = shrinkMinuteData(chartData, groupBy: 10)
        }
        self.myCandleData = chartData
        updateChart()
    }
    
    public func getChartDataCount(timeInteral: Constants.TimeIntervals, candleMode: Bool) -> Int {
        if timeInteral == .day && candleMode {
            return self.myCandleDataTenMin!.count
        }
        return self.myCandleData!.count
    }
    
    public func updateChart(){
        self.previousCloseValue = self.stockDetailsDelegate?.latestQuote.previousClose! ?? 0.0
        var candleEntries:[ChartDataEntry] = []
        var lineEntries:[ChartDataEntry] = []
        var volumeEntries:[BarChartDataEntry] = []
        var candle10minEntries:[ChartDataEntry] = []
        var volume10minEntries:[BarChartDataEntry] = []
        var prevCloseEntries:[ChartDataEntry] = []
        var prevClose10MinEntries:[ChartDataEntry] = []
        var sma20Entries:[ChartDataEntry] = []
        var sma50Entries:[ChartDataEntry] = []
        var sma100Entries:[ChartDataEntry] = []
        var sma200Entries:[ChartDataEntry] = []
        var earningsEntries:[ChartDataEntry] = []
        var entryCount = self.myCandleData!.count

        for i in 0..<self.myCandleData!.count{
            let candle:Candle = self.myCandleData![i]
            let high = candle.high!
            let low = candle.low!
            let open = candle.open!
            let close = candle.close!
            let volume = candle.volume!
  
            candleEntries.append(CandleChartDataEntry(x: Double(i), shadowH: high, shadowL: low, open: open, close: close))
            if candle.earnings ?? false {
                earningsEntries.append(ChartDataEntry(x: Double(i), y: close, icon: UIImage(named: "earnings_with_line_small")))
            }
            sma20Entries.append(ChartDataEntry(x: Double(i), y: candle.sma20 ?? close))
            sma50Entries.append(ChartDataEntry(x: Double(i), y: candle.sma50 ?? close))
            sma100Entries.append(ChartDataEntry(x: Double(i), y: candle.sma100 ?? close))
            sma200Entries.append(ChartDataEntry(x: Double(i), y: candle.sma200 ?? close))
            //line chart
            lineEntries.append(ChartDataEntry(x: Double(i), y: close))
            //volume chart
            volumeEntries.append(BarChartDataEntry(x: Double(i), y: volume))
            //previous close line
            if i == 0 {
                self.firstLineValue = close
                prevCloseEntries.append(ChartDataEntry(x: Double(i), y: previousCloseValue))
            }
        }
        self.lastLineValue = self.myCandleData![self.myCandleData!.count - 1].close!
        prevCloseEntries.append(ChartDataEntry(x: Double(self.myCandleData!.count - 1), y: previousCloseValue))
        
        let candleSet = CandleChartDataSet(entries: candleEntries)
        self.setUpCandleChart(set: candleSet)
        self.candleChartData = CandleChartData(dataSet: candleSet)

        let sma20Set = LineChartDataSet(entries: sma20Entries)
        self.sma20 = sma20Set
        self.setUpSmaLine(set: sma20Set, color: Constants.fadedBlue)
        let sma50Set = LineChartDataSet(entries: sma50Entries)
        self.sma50 = sma50Set
        self.setUpSmaLine(set: sma50Set, color: Constants.fadedOrange)
        let sma100Set = LineChartDataSet(entries: sma100Entries)
        self.sma100 = sma100Set
        self.setUpSmaLine(set: sma100Set, color: Constants.fadedPurple)
        let sma200Set = LineChartDataSet(entries: sma200Entries)
        self.sma200 = sma200Set
        self.setUpSmaLine(set: sma200Set, color: Constants.fadedDarkGrey)
        
        if self.stockDetailsDelegate!.candleMode{
            entryCount = self.myCandleDataTenMin!.count
        }
        for i in 0..<self.myCandleDataTenMin!.count{
            let candle:Candle = self.myCandleDataTenMin![i]
            let high = candle.high!
            let low = candle.low!
            let open = candle.open!
            let close = candle.close!

            if entryCount < 39 && i == entryCount - 1 {
                candle10minEntries.append(CandleChartDataEntry(x: Double(40), shadowH: close, shadowL: close, open: close, close: close))
                volume10minEntries.append(BarChartDataEntry(x: Double(40), y: 0))
            } else {
                candle10minEntries.append(CandleChartDataEntry(x: Double(i), shadowH: high, shadowL: low, open: open, close: close))
                volume10minEntries.append(BarChartDataEntry(x: Double(i), y: candle.volume!))
            }
            if i == 0 {
                prevClose10MinEntries.append(ChartDataEntry(x: Double(i), y: previousCloseValue))
            }
        }
        prevClose10MinEntries.append(ChartDataEntry(x: Double(self.myCandleDataTenMin!.count - 1), y: previousCloseValue))

        let candleSet10min = CandleChartDataSet(entries: candle10minEntries)
        self.setUpCandleChart(set: candleSet10min)
        self.candleChartDataTenMin = CandleChartData(dataSet: candleSet10min)
        
        let volumeSet = BarChartDataSet(entries: volumeEntries)
        self.setUpVolumeChart(set: volumeSet)
        let volumeSet10min = BarChartDataSet(entries: volume10minEntries)
        self.setUpVolumeChart(set: volumeSet10min)

        self.lineChartData = LineChartDataSet(entries: lineEntries)
        self.volumeChartDataTenMin = BarChartData(dataSet: volumeSet10min)
        self.volumeChartData = BarChartData(dataSet: volumeSet)
        self.setUpLineChart(set: self.lineChartData)

        let previousCloseSet = LineChartDataSet(entries: prevCloseEntries)
        let previousCloseSet10min = LineChartDataSet(entries: prevClose10MinEntries)
        self.setUpPreviousLineChart(previousCloseSet: previousCloseSet)
        self.setUpPreviousLineChart(previousCloseSet: previousCloseSet10min)
        
        let earningsSet = ScatterChartDataSet(entries: earningsEntries)
        earningsSet.setColor(UIColor.clear)
        earningsSet.setScatterShape(.square)
        earningsSet.scatterShapeSize = CGFloat(8)
        earningsSet.highlightEnabled = false
        earningsSet.drawIconsEnabled = true
        earningsSet.drawValuesEnabled = false
        earningsSet.iconsOffset = CGPoint(x: 0, y: -12)
        let earningsData = ScatterChartData(dataSet: earningsSet)
        self.earningsData = earningsData
        
        DispatchQueue.main.async {
            let day = self.stockDetailsDelegate?.timeInterval == Constants.TimeIntervals.day
            let data = CombinedChartData()
            var lineDataSets: [LineChartDataSet] = [LineChartDataSet]()
            if day{
                self.drawOrder = [DrawOrder.scatter.rawValue, DrawOrder.bar.rawValue, DrawOrder.line.rawValue, DrawOrder.candle.rawValue]
            } else {
                self.drawOrder = [DrawOrder.bar.rawValue, DrawOrder.line.rawValue, DrawOrder.candle.rawValue, DrawOrder.scatter.rawValue]
            }
            self.leftAxis.axisMaximum =  (self.lineChartData.yMax + ((self.lineChartData.yMax - self.lineChartData.yMin) * 0.18))
            if self.stockDetailsDelegate!.candleMode {
                if day {
                    data.barData = self.volumeChartDataTenMin
                    data.candleData = self.candleChartDataTenMin
                    if self.shouldShowPreviousLine() {
                        lineDataSets.append(previousCloseSet10min)
                    }
                } else {
                    if self.stockDetailsDelegate!.showSmas {
                        lineDataSets.append(self.sma20)
                        lineDataSets.append(self.sma50)
                        lineDataSets.append(self.sma100)
                        lineDataSets.append(self.sma200)
                    }
                    data.barData = self.volumeChartData
                    data.candleData = self.candleChartData
                }
            } else {
                lineDataSets.append(self.lineChartData)
                if day {
                    lineDataSets.append(self.createSinglePointLineChartDataSet(index: 391, value: self.lineChartData.yMin))
                    if self.shouldShowPreviousLine() {
                        lineDataSets.append(previousCloseSet)
                    }
                } else {
                    if self.stockDetailsDelegate!.showSmas {
                        lineDataSets.append(self.sma20)
                        lineDataSets.append(self.sma50)
                        lineDataSets.append(self.sma100)
                        lineDataSets.append(self.sma200)
                    }
                    data.scatterData = earningsData
                }
                data.barData = self.volumeChartData
            }
            let lineChartDatas:LineChartData = LineChartData(dataSets: lineDataSets)
            data.lineData = lineChartDatas
            self.xAxis.axisMaximum = data.xMax + 1.5
            self.rightAxis.axisMaximum = data.barData.yMax * 2
            self.rightAxis.axisMinimum = 0
            self.data = data
            self.notifyDataSetChanged()
            //self.animate()
        }
    }
    
    //TODO-SAM: animated boolean for each time frame
//    public func animate(){
//        if !animated {
//            self.animate(xAxisDuration: 0.25, yAxisDuration: 0.0, easingOption: .linear)
//        }
//        self.animated = true
//    }
    
    private func shouldShowPreviousLine() -> Bool {
        let maxVal = self.lineChartData.yMax
        let minVal = self.lineChartData.yMin
        let day = self.stockDetailsDelegate?.timeInterval == Constants.TimeIntervals.day
        if day && (self.previousCloseValue <= (1.02*maxVal) && self.previousCloseValue >= (0.98*minVal)) {
            return true
        }
        return false
    }
    
    private func setUpCandleChart(set: CandleChartDataSet){
        set.axisDependency = .left
        //set.setColor(UIColor.white)
        set.drawIconsEnabled = true
        set.shadowColor = .darkGray
        set.shadowWidth = 0.7
        set.decreasingColor = Constants.darkPink
        set.decreasingFilled = true
        set.increasingColor = Constants.green
        set.increasingFilled = true
        set.neutralColor = .white
        set.highlightColor = UIColor.gray
        set.highlightLineWidth = 2
        set.drawHorizontalHighlightIndicatorEnabled = false
        set.drawValuesEnabled = false
    }
    
    private func setUpVolumeChart(set: BarChartDataSet){
        set.axisDependency = .right
        set.setColor(Constants.fadedOrange)
        set.highlightEnabled = false
        set.drawValuesEnabled = false
    }
    
    private func setUpPreviousLineChart(previousCloseSet: LineChartDataSet){
        previousCloseSet.setColor(UIColor.darkGray)
        previousCloseSet.highlightEnabled = false
        previousCloseSet.drawValuesEnabled = false
        previousCloseSet.lineDashLengths = [5, 5]
        previousCloseSet.drawCirclesEnabled = false
    }
    
    private func setUpSmaLine(set: LineChartDataSet, color: UIColor){
        set.setColor(color)
        set.lineWidth = 2
        set.drawCirclesEnabled = false
        set.mode = .cubicBezier
        set.drawValuesEnabled = false
        set.axisDependency = .left
        set.highlightEnabled = false
    }
    
    private func setUpLineChart(set: LineChartDataSet){
        let day = self.stockDetailsDelegate?.timeInterval == Constants.TimeIntervals.day
        let firstValue = day ? self.previousCloseValue : self.firstLineValue
        let color = self.lastLineValue > firstValue ? Constants.green : Constants.darkPink
        set.setColor(color)
        set.lineWidth = 2
        set.drawCirclesEnabled = false
        set.mode = .cubicBezier
        set.axisDependency = .left
        set.highlightColor = UIColor.gray
        set.highlightLineWidth = 2
        set.drawHorizontalHighlightIndicatorEnabled = false
        set.drawValuesEnabled = false
        //set.setCircleColor(Constants.purple)
        //set.circleRadius = 5
        //set.circleHoleRadius = 2.5
        //set.fillColor = Constants.darkPink
        //set.drawFilledEnabled = true
        //set.fillAlpha = 1
        //let gradientColors = [Constants.darkPink.cgColor, UIColor.clear.cgColor] as CFArray // Colors of the gradient
        //let colorLocations:[CGFloat] = [1.0, 0.0] // Positioning of the gradient
        //let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations) // Gradient Object
        //set.fill = Fill.fillWithLinearGradient(gradient!, angle: 90.0) // Set the Gradient
    }
    
    private func shrinkMinuteData(_ chartData: [Candle], groupBy: Int) -> [Candle]{
        var dataSet:[Candle] = []
        var counter = 0
        var high = 0.0, low = 0.0, open = 0.0, volume = 0.0
        var date:String = ""
        for candle in chartData {
            counter += 1
            if counter == 1 {
                high = candle.high!
                low = candle.low!
                open = candle.open!
                volume = candle.volume!
                date = candle.datetime!
            } else {
                volume += candle.volume!
                if candle.high! > high {
                    high = candle.high!
                }
                if candle.low! < low {
                    low = candle.low!
                }
                if counter == groupBy || counter == chartData.count - 1{
                    let candle = Candle(datetime: date, volume: volume, high: high, low: low, open: open, close: candle.close!)
                    dataSet.append(candle)
                    counter = 0
                    volume = 0.0
                }
            }
        }
        return dataSet
    }
    
    private func shrinkCandleData(_ chartData: [Candle], groupBy: Int) -> [Candle]{
           var dataSet:[Candle] = []
           var counter = 0
           var high = 0.0, low = 0.0, open = 0.0, volume = 0.0
           var date:String = ""
           for candle in chartData {
               counter += 1
               if counter == 1 {
                   high = candle.high!
                   low = candle.low!
                   open = candle.open!
                   volume = candle.volume!
                   date = candle.datetime!
               } else {
                   volume += candle.volume!
                   if candle.high! > high {
                       high = candle.high!
                   }
                   if candle.low! < low {
                       low = candle.low!
                   }
                   if counter == groupBy || counter == chartData.count - 1{
                       let candle = Candle(datetime: date, volume: volume, high: high, low: low, open: open, close: candle.close!)
                       dataSet.append(candle)
                       counter = 0
                       volume = 0.0
                   }
               }
           }
           return dataSet
       }
    
    public func showCandleChart(){
        self.updateChart()
    }
    
    public func showLineChart(){
        self.updateChart()
    }
    
    private func createSinglePointLineChartDataSet(index: Double, value: Double) -> LineChartDataSet{
        var yVals : [ChartDataEntry] = [ChartDataEntry]()
        yVals.append(ChartDataEntry(x: Double(index), y: value))
        let set =  LineChartDataSet(entries: yVals)
        set.drawCirclesEnabled = false
        set.drawValuesEnabled = false
        return set
    }
    
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
