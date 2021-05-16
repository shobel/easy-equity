//
//  RatingsChart.swift
//  stonks
//
//  Created by Samuel Hobel on 8/15/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import UIKit
import Charts

class RatingsChart: BarChartView {

    private var predictionsDelegate: PredictionsViewController!
    private var company:Company!
    private var xlabels = ["Strong Buy", "Buy", "Hold", "Sell", "Strong Sell"]
    public var animated:Bool = false
    private var allMode:Bool!

    public func setup(company:Company, predictionsDelegate: PredictionsViewController, allMode: Bool){
        self.allMode = allMode
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
        
        self.leftAxis.drawGridLinesEnabled = false
        self.leftAxis.drawAxisLineEnabled = false
        self.leftAxis.enabled = false
        self.leftAxis.axisMinimum = 0.0
        self.rightAxis.enabled = false
                
        self.xAxis.valueFormatter = self
        self.xAxis.enabled = true
        self.xAxis.axisMinimum = -0.5
        self.xAxis.drawGridLinesEnabled = false
        self.xAxis.labelPosition = .bottom
        self.xAxis.granularity = 1
        self.xAxis.drawAxisLineEnabled = true
        self.xAxis.wordWrapEnabled = true
        self.xAxis.labelTextColor = .black

        self.drawBarShadowEnabled = true
        self.extraTopOffset = 10 //isnt doing anything
        self.extraBottomOffset = 20
        self.setChartData()

    }
         
    private func setChartData(){
        var buy:Int = 0
        var overweight:Int = 0
        var hold:Int = 0
        var underweight:Int = 0
        var sell:Int = 0
        var overall:Double = 0.0
        
        if let topRatings = self.company.priceTargetTopAnalysts?.expertRatings {
            for rating in topRatings {
                if var pos = rating.stockRating?.position {
                    pos = pos.lowercased()
                    switch pos {
                    case "buy":
                        buy += 1
                        break
                    case "hold":
                        hold += 1
                        break
                    case "sell":
                        sell += 1
                        break
                    default:
                        break
                    }
                }
            }
        }
        
        if allMode {
            if let r = self.company.recommendations {
                buy += r.ratingBuy ?? 0
                overweight += r.ratingOverweight ?? 0
                hold += r.ratingHold ?? 0
                underweight += r.ratingUnderweight ?? 0
                sell += r.ratingSell ?? 0
                overall += r.ratingScaleMark ?? 0.0
            }
            if let allRatings = self.company.tipranksAllAnalysts {
                for rating in allRatings {
                    if var pos = rating.stockRating?.position {
                        pos = pos.lowercased()
                        switch pos {
                        case "buy":
                            overweight += 1
                            break
                        case "hold":
                            hold += 1
                            break
                        case "sell":
                            underweight += 1
                            break
                        default:
                            break
                        }
                    }
                }
            }
        }
        
        
        let scoredSum = (buy*5) + (overweight*4) + (hold*3) + (underweight*2) + (sell*1)
        let maxScore = (buy + overweight + hold + underweight + sell)*5
        self.predictionsDelegate.setOverallRecommendationScore(Double(scoredSum) / Double(maxScore))
        
        var barChartEntries:[BarChartDataEntry] = []
        barChartEntries.append(BarChartDataEntry(x: 0, y: Double(buy)))
        barChartEntries.append(BarChartDataEntry(x: 1, y: Double(overweight)))
        barChartEntries.append(BarChartDataEntry(x: 2, y: Double(hold)))
        barChartEntries.append(BarChartDataEntry(x: 3, y: Double(underweight)))
        barChartEntries.append(BarChartDataEntry(x: 4, y: Double(sell)))
        let set = BarChartDataSet(entries: barChartEntries)
        
        set.colors = [
            UIColor(red: 70.0/255.0, green: 180.0/255.0, blue: 88.0/255.0, alpha: 1.0),
            UIColor(red: 164.0/255.0, green: 217.0/255.0, blue: 51.0/255.0, alpha: 1.0),
            Constants.yellow,
            UIColor(red: 238.0/255.0, green: 143.0/255.0, blue: 29.0/255.0, alpha: 1.0),
            Constants.darkPink
        ]
        
        set.barShadowColor = Constants.veryLightGrey
        set.valueTextColor = Constants.darkGrey
        set.drawValuesEnabled = true
        set.highlightEnabled = false
        set.valueFormatter = self
        set.valueFont = UIFont(name: "Futura-Bold", size: 12)!
        
        DispatchQueue.main.async {
            let data = BarChartData(dataSet: set)
            data.barWidth = 0.4
            self.data = data
            self.notifyDataSetChanged()
        }
    }
    
    public func animate(){
        if !animated {
            self.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .easeOutExpo)
        }
        self.animated = true
    }
}

extension RatingsChart: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return xlabels[Int(value) % xlabels.count]
    }
}

extension RatingsChart: IValueFormatter {
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        return String(Int(value.rounded()))
    }
}
