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
    private var volumeView:BarChartView!
    
    private var myCandleData:[Candle]?
    private var myCandleDataTenMin:[Candle]?
    
    private var candleChartData:CandleChartData = CandleChartData()
    private var lineChartData:LineChartDataSet = LineChartDataSet()
    private var volumeChartData:BarChartData = BarChartData()
    private var volumeChartDataTenMin:BarChartData = BarChartData()
    
    public func setup(delegate: StockDetailsVC, volumeView: BarChartView){
        self.volumeView = volumeView
        self.volumeChartFormatter = volumeView.leftAxis.valueFormatter as? VolumeChartFormatter
        self.delegate = delegate
        self.stockDetailsDelegate = delegate
        
        self.chartDescription?.enabled = false
        self.legend.enabled = false
        self.dragEnabled = true
        self.setScaleEnabled(false)
        self.maxVisibleCount = 200
        self.pinchZoomEnabled = false
        self.doubleTapToZoomEnabled = false
        self.autoScaleMinMaxEnabled = true
        
        self.leftAxis.labelFont = UIFont(name: "HelveticaNeue-Light", size: 10)!
        self.leftAxis.spaceTop = 0.1
        self.leftAxis.spaceBottom = 0.1
        //candleChartView.leftAxis.axisMinimum = 0
        self.leftAxis.drawGridLinesEnabled = false
        
        self.rightAxis.enabled = false
        
        self.xAxis.labelPosition = .bottom
        self.xAxis.labelFont = UIFont(name: "HelveticaNeue-Light", size: 10)!
        self.xAxis.drawGridLinesEnabled = false
        self.xAxis.valueFormatter = priceChartFormatter
        
        self.drawOrder = [DrawOrder.line.rawValue, DrawOrder.candle.rawValue]
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
            self.myCandleData = chartData
        } else if self.stockDetailsDelegate?.timeInterval == Constants.TimeIntervals.one_year {
            self.myCandleData = shrinkMinuteData(chartData, groupBy: 7)
        } else if self.stockDetailsDelegate?.timeInterval == Constants.TimeIntervals.five_year {
            
        }
        self.myCandleData = chartData
        updateChart()
    }
    
    public func updateChart(){
        var currentCandleData = self.myCandleData
        var day = false
        if self.stockDetailsDelegate!.timeInterval == Constants.TimeIntervals.day {
            currentCandleData = self.myCandleDataTenMin
            day = true
        }
        priceChartFormatter.resetXAxisLabels()
        let currentCount = currentCandleData!.count
        let yVals1 = currentCandleData!.enumerated().map { (index: Int, candle:Candle) -> ChartDataEntry in
            let high = candle.high!
            let low = candle.low!
            let open = candle.open!
            let close = candle.close!
            if day && (currentCount < 39 && index == currentCount-1) {
                return CandleChartDataEntry(x: Double(40), shadowH: close, shadowL: close, open: close, close: close)
            }
            priceChartFormatter.addXAxisLabelTenMin(candle.datetime!)
            return CandleChartDataEntry(x: Double(index), shadowH: high, shadowL: low, open: open, close: close)
        }
        let set1 = CandleChartDataSet(entries: yVals1, label: "Price")
        set1.axisDependency = .left
        set1.setColor(UIColor.white)//(UIColor(white: 80/255, alpha: 1))
        set1.drawIconsEnabled = true
        set1.shadowColor = .darkGray
        set1.shadowWidth = 0.7
        set1.decreasingColor = Constants.darkPink
        set1.decreasingFilled = true
        set1.increasingColor = Constants.green
        set1.increasingFilled = true
        set1.neutralColor = .white
        set1.highlightColor = Constants.darkPink
        set1.highlightLineWidth = 2
        set1.drawHorizontalHighlightIndicatorEnabled = false
        set1.drawValuesEnabled = false
        
        volumeChartFormatter.resetAxisLabels()

        //minute volume data
        let volumeCount = self.myCandleData!.count
        let yVals2 = self.myCandleData!.enumerated().map { (index: Int, candle:Candle) -> BarChartDataEntry in
            volumeChartFormatter.addAxisLabel(candle.volume!)
            if day && (volumeCount < 391 && index == volumeCount-1) {
                return BarChartDataEntry(x: Double(391), y: 0)
            }
            return BarChartDataEntry(x: Double(index), y: candle.volume!)
        }
        let set2 = BarChartDataSet(entries: yVals2, label: "Volume")
        set2.setColor(Constants.orange)
        
        let candleCount = self.myCandleDataTenMin!.count
        if let x = self.myCandleDataTenMin {
            let yVals3 = x.enumerated().map { (index: Int, candle:Candle) -> BarChartDataEntry in
                volumeChartFormatter.addAxisLabel(candle.volume!)
                if day && (candleCount < 39 && index == candleCount-1) {
                    return BarChartDataEntry(x: Double(40), y: 0)
                }
                return BarChartDataEntry(x: Double(index), y: candle.volume!)
            }
            let set3 = BarChartDataSet(entries: yVals3, label: "Volume")
            set3.setColor(Constants.blue)
            //10min volume
            self.volumeChartDataTenMin = BarChartData(dataSet: set3)
        }
        
        //1min volume
        self.volumeChartData = BarChartData(dataSet: set2)
        
        //10min price data
        self.candleChartData = CandleChartData(dataSet: set1)
        
        //1min price data
        self.lineChartData = self.generateLineData()
        
        DispatchQueue.main.async {
            let data = CombinedChartData()
            if self.stockDetailsDelegate!.candleMode {
                if self.stockDetailsDelegate?.timeInterval == Constants.TimeIntervals.day{
                    self.volumeView.data = self.volumeChartDataTenMin
                } else {
                    self.volumeView.data = self.volumeChartData
                }
                data.candleData = self.candleChartData
                self.priceChartFormatter.setActiveLabels("candle")
            } else {
                var lineDataSets : [LineChartDataSet] = [LineChartDataSet]()
                lineDataSets.append(self.lineChartData)
                if self.stockDetailsDelegate?.timeInterval == Constants.TimeIntervals.day {
                    lineDataSets.append(self.createSinglePointLineChartDataSet(index: 391, value: self.lineChartData.yMin))
                }
                let lineChartDatas:LineChartData = LineChartData(dataSets: lineDataSets)
                data.lineData = lineChartDatas
                self.volumeView.data = self.volumeChartData
                self.priceChartFormatter.setActiveLabels("line")
            }
            self.volumeView.data?.setDrawValues(false)
            self.data = data
        }
    }
    
    func generateLineData() -> LineChartDataSet {
        var entries:[ChartDataEntry] = []
        entries = (0..<self.myCandleData!.count).map { (i) -> ChartDataEntry in
            let y:Candle = self.myCandleData![i]
            priceChartFormatter.addXAxisLabelFull(y.datetime!)
            return ChartDataEntry(x: Double(i), y: y.close!)
        }
        
        let set = LineChartDataSet(entries: entries, label: "Line DataSet")
        set.setColor(Constants.darkPink)
        set.lineWidth = 2
        set.drawCirclesEnabled = false
        //set.setCircleColor(Constants.purple)
        //set.circleRadius = 5
        //set.circleHoleRadius = 2.5
        //set.fillColor = Constants.darkPink
//        set.drawFilledEnabled = true
//        set.fillAlpha = 1
//        let gradientColors = [Constants.darkPink.cgColor, UIColor.clear.cgColor] as CFArray // Colors of the gradient
//        let colorLocations:[CGFloat] = [1.0, 0.0] // Positioning of the gradient
//        let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations) // Gradient Object
//        set.fill = Fill.fillWithLinearGradient(gradient!, angle: 90.0) // Set the Gradient
        
        set.mode = .cubicBezier
        set.drawValuesEnabled = false
        set.axisDependency = .left
        set.highlightColor = Constants.darkPink
        set.highlightLineWidth = 2
        set.drawHorizontalHighlightIndicatorEnabled = false
        set.drawValuesEnabled = false
        
        //return LineChartData(dataSet: set)
        return set
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
    
    public func showCandleChart(){
        priceChartFormatter.setActiveLabels("candle")
        for i in 0...self.data!.dataSets.count {
            self.data?.removeDataSetByIndex(i)
        }
        let data = CombinedChartData()
        data.candleData = self.candleChartData
        self.data = data
        
        if self.stockDetailsDelegate?.timeInterval == Constants.TimeIntervals.day{
            self.volumeView.data = self.volumeChartDataTenMin
        }
        self.volumeView.data?.setDrawValues(false)
        self.volumeView.notifyDataSetChanged()
        self.notifyDataSetChanged()
    }
    
    public func showLineChart(){
        priceChartFormatter.setActiveLabels("line")
        for i in 0...self.data!.dataSets.count {
            self.data?.removeDataSetByIndex(i)
        }
        let data = CombinedChartData()
        var lineDataSets : [LineChartDataSet] = [LineChartDataSet]()
        lineDataSets.append(self.lineChartData)
        if self.stockDetailsDelegate?.timeInterval == Constants.TimeIntervals.day {
            lineDataSets.append(self.createSinglePointLineChartDataSet(index: 391, value: self.lineChartData.yMin))
        }
        let lineChartDatas:LineChartData = LineChartData(dataSets: lineDataSets)
        data.lineData = lineChartDatas
        self.data = data
        self.volumeView.data = self.volumeChartData
        self.volumeView.data?.setDrawValues(false)
        self.volumeView.notifyDataSetChanged()
        self.notifyDataSetChanged()
    }
    
    private func createSinglePointLineChartDataSet(index: Double, value: Double) -> LineChartDataSet{
        var yVals : [ChartDataEntry] = [ChartDataEntry]()
        yVals.append(ChartDataEntry(x: Double(index), y: value))
        let set =  LineChartDataSet(entries: yVals, label: "")
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
