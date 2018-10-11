//
//  StockDetailsVC.swift
//  stonks
//
//  Created by Samuel Hobel on 10/9/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import UIKit
import Charts

class StockDetailsVC: DemoBaseViewController {

    @IBOutlet weak var chartView: CandleStickChartView!
    @IBOutlet weak var candlePricesWrapper: UIView!
    @IBOutlet weak var candlePricesView: CandlePricesView!
    @IBOutlet weak var markerView: MarkerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        load()
    }
    
    func load(){
        
        self.title = "Candle Stick Chart"
        self.options = [.toggleValues,
                        .toggleIcons,
                        .toggleHighlight,
                        .animateX,
                        .animateY,
                        .animateXY,
                        .saveToGallery,
                        .togglePinchZoom,
                        .toggleAutoScaleMinMax,
                        .toggleShadowColorSameAsCandle,
                        .toggleShowCandleBar,
                        .toggleData]
        
        chartView.delegate = self
        chartView.chartDescription?.enabled = false
        chartView.legend.enabled = false
        chartView.dragEnabled = false
        chartView.setScaleEnabled(true)
        chartView.maxVisibleCount = 200
        chartView.pinchZoomEnabled = false
        chartView.doubleTapToZoomEnabled = false
        chartView.autoScaleMinMaxEnabled = true
        
        chartView.leftAxis.labelFont = UIFont(name: "HelveticaNeue-Light", size: 10)!
        chartView.leftAxis.spaceTop = 0.3
        chartView.leftAxis.spaceBottom = 0.3
        //chartView.leftAxis.axisMinimum = 0
        chartView.leftAxis.drawGridLinesEnabled = false
        
        chartView.rightAxis.enabled = false
        
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.labelFont = UIFont(name: "HelveticaNeue-Light", size: 10)!
        chartView.xAxis.drawGridLinesEnabled = false
        updateChartData()

    }
    
    override func updateChartData() {
        if self.shouldHideData {
            chartView.data = nil
            return
        }
        
        self.setDataCount(Int(60), range: UInt32(100))
    }
    
    func setDataCount(_ count: Int, range: UInt32) {
        let yVals1 = (0..<count).map { (i) -> CandleChartDataEntry in
            let mult = range + 1
            let val = Double(arc4random_uniform(40) + mult)
            let high = Double(arc4random_uniform(9) + 8)
            let low = Double(arc4random_uniform(9) + 8)
            let open = Double(arc4random_uniform(6) + 1)
            let close = Double(arc4random_uniform(6) + 1)
            let even = i % 2 == 0
            
            return CandleChartDataEntry(x: Double(i), shadowH: val + high, shadowL: val - low, open: even ? val + open : val - open, close: even ? val - close : val + close, icon: nil)
        }
        
        let set1 = CandleChartDataSet(values: yVals1, label: "Data Set")
        set1.axisDependency = .left
        set1.setColor(UIColor(white: 80/255, alpha: 1))
        set1.drawIconsEnabled = false
        set1.shadowColor = .darkGray
        set1.shadowWidth = 0.7
        set1.decreasingColor = Constants.darkPink
        set1.decreasingFilled = true
        set1.increasingColor = Constants.green
        set1.increasingFilled = true
        set1.neutralColor = .blue
        set1.highlightColor = Constants.darkPink
        set1.highlightLineWidth = 2
        set1.drawHorizontalHighlightIndicatorEnabled = false
        
        let data = CandleChartData(dataSet: set1)
        chartView.data = data
        chartView.candleData?.setDrawValues(false)
    }
    
    override func optionTapped(_ option: Option) {
        switch option {
        case .toggleShadowColorSameAsCandle:
            for set in chartView.data!.dataSets as! [CandleChartDataSet] {
                set.shadowColorSameAsCandle = !set.shadowColorSameAsCandle
            }
            chartView.notifyDataSetChanged()
        case .toggleShowCandleBar:
            for set in chartView.data!.dataSets as! [CandleChartDataSet] {
                set.showCandleBar = !set.showCandleBar
            }
            chartView.notifyDataSetChanged()
        default:
            super.handleOption(option, forChartView: chartView)
        }
    }
    
    override func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        let e = entry as! CandleChartDataEntry
        candlePricesView.volumeLabel.text = "VOL:17.68k"
        candlePricesView.highLabel.text = "HIGH:\(e.high)"
        candlePricesView.lowLabel.text = "LOW:\(e.low)"
        candlePricesView.openLabel.text = "OPEN:\(e.open)"
        candlePricesView.closeLabel.text = "CLOSE:\(e.close)"
        candlePricesWrapper.isHidden = false
        
        //let graphPoint = chartView.getMarkerPosition(highlight: highlight)
        // Adding top marker
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        let time = formatter.string(from: currentDateTime)
        markerView.dateLabel.text = "\(time)"
        var x = highlight.xPx.rounded()
        if x+(markerView.bounds.width/2) > chartView.bounds.width {
            x = chartView.bounds.width - (markerView.bounds.width/2)
        }
        if x-(markerView.bounds.width/2) < 0 {
            x = (markerView.bounds.width/2)
        }
        markerView.center = CGPoint(x: x, y:10.0)
        markerView.isHidden = false
        
    }
    
    override func chartValueNothingSelected(_ chartView: ChartViewBase) {
        candlePricesWrapper.isHidden = true
        markerView.isHidden = true
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
