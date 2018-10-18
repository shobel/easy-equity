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

    @IBOutlet weak var stockDetailsNavView: StockDetailsNavView!
    @IBOutlet weak var priceDetailsView: StockDetailsSummaryView!
    @IBOutlet weak var chartView: CandleStickChartView!
    @IBOutlet weak var candlePricesWrapper: UIView!
    @IBOutlet weak var candlePricesView: CandlePricesView!
    @IBOutlet weak var markerView: MarkerView!
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    
    private var company:Company!
    private var chartData:[Candle] = []
    private var feedbackGenerator: UISelectionFeedbackGenerator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        feedbackGenerator = UISelectionFeedbackGenerator()
        stockDetailsNavView.logo.layer.cornerRadius = (stockDetailsNavView.logo.frame.width)/2
        stockDetailsNavView.logo.layer.masksToBounds = true
        
        company = Dataholder.watchlistManager.selectedCompany
        stockDetailsNavView.ticker.text = company.ticker
        stockDetailsNavView.name.text = company.fullName
        
        StockAPIManager.shared.stockDataApiInstance.getCompanyData(ticker: company.ticker, completionHandler: handleCompanyData)
        StockAPIManager.shared.stockDataApiInstance.getChart(ticker: company.ticker, timeInterval: .day, completionHandler: handleChart)
        
        /*
         We have a custom nav panel and so the default one goes on the bottom for some reason
        and then our tab bar at the bottom gets darker
         */
        self.navigationController?.view.backgroundColor = UIColor.white
        loadChart()
    }
    
    //handles the description, ceo, and logo
    private func handleCompanyData(_ data:[String:String]){
        let url = URL(string: data["logo"]!)
        let data = try? Data(contentsOf: url!)
        
        if let imageData = data {
            updateUI {
                self.stockDetailsNavView.logo.contentMode = .scaleAspectFit
                self.stockDetailsNavView.logo.image = UIImage(data: imageData)
            }
        }
    }
    
    private func handleChart(_ chartData:[Candle]){
        self.chartData = chartData
        updateChartData()
    }
    
    public func updateUI(function: @escaping ()->Void){
        DispatchQueue.main.async {
            function()
        }
    }
    
    func loadChart(){
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
        chartView.dragEnabled = true
        chartView.setScaleEnabled(true)
        chartView.maxVisibleCount = 200
        chartView.pinchZoomEnabled = true
        chartView.doubleTapToZoomEnabled = false
        chartView.autoScaleMinMaxEnabled = true
        
        chartView.leftAxis.labelFont = UIFont(name: "HelveticaNeue-Light", size: 10)!
        chartView.leftAxis.spaceTop = 0.1
        chartView.leftAxis.spaceBottom = 0.1
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
        
        //self.setDataCount(Int(60), range: UInt32(100))
        if (!chartData.isEmpty) {
            setData(chartData: chartData)
        }
    }
    
    func setData(chartData:[Candle]){
        var dataSet:[Candle] = []
        var counter = 0
        var high = 0.0, low = 0.0, open = 0.0, volume = 0.0
        var date:String = ""
        for candle in chartData {
            counter += 1
            if counter == 1 {
                high = candle.high
                low = candle.low
                open = candle.open
                volume = candle.volume
                date = candle.datetime
            } else {
                volume += candle.volume
                if candle.high > high {
                    high = candle.high
                }
                if candle.low < low {
                    low = candle.low
                }
                if counter == 10 {
                    let candle = Candle(date: date, volume: volume, high: high, low: low, open: open, close: candle.close)
                    dataSet.append(candle)
                    counter = 0
                    volume = 0.0
                }
            }
        }
        
        self.chartData = dataSet
        
        let yVals1 = dataSet.enumerated().map { (index: Int, candle:Candle) -> CandleChartDataEntry in
            let high = candle.high
            let low = candle.low
            let open = candle.open
            let close = candle.close

            return CandleChartDataEntry(x: Double(index), shadowH: high, shadowL: low, open: open, close: close)
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
        DispatchQueue.main.async {
            self.chartView.data = data
            self.chartView.candleData?.setDrawValues(false)
            //self.chartView.notifyDataSetChanged()
            //self.chartView.data?.notifyDataChanged()
            //self.chartView.setNeedsDisplay()
        }
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
        let candle = self.chartData[Int(e.x)]
        let volumeString = formatNumber(num: candle.volume)
        candlePricesView.volumeLabel.text = "VOL:" + volumeString
        candlePricesView.highLabel.text = "HIGH:\(e.high)"
        candlePricesView.lowLabel.text = "LOW:\(e.low)"
        candlePricesView.openLabel.text = "OPEN:\(e.open)"
        candlePricesView.closeLabel.text = "CLOSE:\(e.close)"
        candlePricesWrapper.isHidden = false
        
        // Adding top marker
        markerView.dateLabel.text = "\(candle.datetime)"
        var x = highlight.xPx.rounded()
        if x+(markerView.bounds.width/2) > chartView.bounds.width {
            x = chartView.bounds.width - (markerView.bounds.width/2)
        }
        if x-(markerView.bounds.width/2) < 0 {
            x = (markerView.bounds.width/2)
        }
        markerView.center = CGPoint(x: x, y:10.0)
        markerView.isHidden = false
        
        priceDetailsView.priceLabel.text = "\(candle.close)"
        feedbackGenerator.selectionChanged()
    }
    
    override func chartValueNothingSelected(_ chartView: ChartViewBase) {
        candlePricesWrapper.isHidden = true
        markerView.isHidden = true
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func formatNumber(num:Double) -> String {
        if num > 999 {
            return String(num/100) + "K"
        }
        return String(num)
    }
    
    //leaving this pangesturerecognizer in case we want to add a draw function on the chart
    @IBAction func handlePan(_ sender: Any) {
//        if panGestureRecognizer.state == .began || panGestureRecognizer.state == .changed {
//
//            let location = panGestureRecognizer.location(in: self.chartView)
//            let translation = panGestureRecognizer.translation(in: self.chartView)
//
//            let dotPath = UIBezierPath(ovalIn: CGRect(origin: location, size: CGSize(width: 5, height: 5)))
//            let layer = CAShapeLayer()
//            layer.path = dotPath.cgPath
//            layer.strokeColor = UIColor.blue.cgColor
//            chartView.layer.addSublayer(layer)
//        }
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
