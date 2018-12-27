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
    @IBOutlet weak var volumeView: BarChartView!
    @IBOutlet weak var candlePricesWrapper: UIView!
    @IBOutlet weak var candlePricesView: CandlePricesView!
    @IBOutlet weak var markerView: MarkerView!
    @IBOutlet weak var chartTypeButton: UIButton!
    
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    
    @IBOutlet weak var datetime: UILabel!
    @IBOutlet weak var ytdChange: ColoredValueLabel!
    @IBOutlet weak var yrHighValue: ColoredValueLabel!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    private var company:Company!
    private var latestQuote:Quote!
    private var chartData:[Candle] = []
    private var priceChartFormatter:PriceChartFormatter!
    private var volumeChartFormatter:VolumeChartFormatter!

    private var feedbackGenerator: UISelectionFeedbackGenerator!
    private var candleMode = true
    private var timeInterval = Constants.TimeIntervals.day
    private var timeButtons:[UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pageVC: StatsNewsPageViewController = self.children.first as! StatsNewsPageViewController
        pageVC.pageDelegate = self
        volumeView.delegate = self
        /* We have a custom nav panel and so the default one goes on the bottom for some reason
         and then our tab bar at the bottom gets darker */
        self.navigationController?.view.backgroundColor = UIColor.white
        
        chartTypeButton.imageView!.contentMode = UIView.ContentMode.scaleAspectFit
        feedbackGenerator = UISelectionFeedbackGenerator()
        
        //setup general stock and price information
        company = Dataholder.watchlistManager.selectedCompany
        stockDetailsNavView.logo.layer.cornerRadius = (stockDetailsNavView.logo.frame.width)/2
        stockDetailsNavView.logo.layer.masksToBounds = true
        stockDetailsNavView.ticker.text = company.ticker
        stockDetailsNavView.name.text = company.fullName
        
        latestQuote = company.quote
        //setup price info that will need to be updated each time quote is retreived
        setTopBarValues(startPrice: 0.0, endPrice: latestQuote.latestPrice, selected: false)
        
        //start information retrieval processes
        StockAPIManager.shared.stockDataApiInstance.getCompanyData(ticker: company.ticker, completionHandler: handleCompanyData)
        StockAPIManager.shared.stockDataApiInstance.getChart(ticker: company.ticker, timeInterval: .day, completionHandler: handleDayChartData)
        StockAPIManager.shared.stockDataApiInstance.getChart(ticker: company.ticker, timeInterval: .five_year, completionHandler: handleFullChartData)
        
        //setup chart buttons
        timeButtons = [button1D, button1M, button3M, button6M, button1Y, button5Y]
        button1D.backgroundColor = UIColor.white
        button1D.setTitleColor(Constants.darkGrey, for: .normal)
        priceChartFormatter = PriceChartFormatter()
        volumeChartFormatter = VolumeChartFormatter()
        timeInterval = Constants.TimeIntervals.day
        
        //load charts
        loadPriceChart()
        loadVolumeChart()
        updateChartData()
    }
    
    //when receving new quote, call this to update top bar values
    private func setTopBarValues(startPrice: Double, endPrice: Double, selected: Bool){
        priceDetailsView.priceLabel.text = String(format: "%.2f", endPrice)
        
        if timeInterval == Constants.TimeIntervals.day && !selected {
            priceDetailsView.priceChangeAndPercent.setPriceChange(price: latestQuote.change, percent: latestQuote.changePercent)
        } else {
            let priceChange = endPrice - startPrice
            let percentChange = (priceChange / startPrice)*100
            priceDetailsView.priceChangeAndPercent.setPriceChange(price: priceChange, percent: percentChange)
        }
        
        if latestQuote.latestTime.contains(":"){
            datetime.text = latestQuote.latestTime + " ET"
        } else {
            datetime.text = latestQuote.latestTime
        }
        ytdChange.setValue(value: latestQuote.ytdChange, isPercent: true)
        yrHighValue.setValue(value: latestQuote.getYrHighChangePercent(), isPercent: true)
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
    
    private func handleDayChartData(_ chartData:[Candle]){
        if chartData.isEmpty {
            let date = ""
            //get most recent date from company.dailyData
            StockAPIManager.shared.stockDataApiInstance.getChartForDate(ticker: company.ticker, date: date, completionHandler: handleDayChartData(_:))
        } else {
            company.minuteData = chartData
            self.chartData = company.minuteData
            updateChartData()
        }
    }
    
    private func handleFullChartData(_ chartData:[Candle]){
        company.dailyData = chartData
    }
    
    public func updateUI(function: @escaping ()->Void){
        DispatchQueue.main.async {
            function()
        }
    }
    
    func loadPriceChart(){
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
        chartView.pinchZoomEnabled = false
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
        chartView.xAxis.valueFormatter = priceChartFormatter
    }
    
    private func loadVolumeChart(){
        volumeView.delegate = self
        volumeView.chartDescription?.enabled = false
        volumeView.legend.enabled = false
        volumeView.highlightPerTapEnabled = false
        volumeView.dragEnabled = false
        volumeView.setScaleEnabled(true)
        volumeView.maxVisibleCount = 200
        volumeView.pinchZoomEnabled = false
        volumeView.doubleTapToZoomEnabled = false
        volumeView.autoScaleMinMaxEnabled = true
        
        volumeView.leftAxis.drawGridLinesEnabled = false
        volumeView.rightAxis.enabled = false
        //volumeView.leftAxis.enabled = false
        volumeView.xAxis.enabled = false
        volumeView.xAxis.drawGridLinesEnabled = false
        volumeView.leftAxis.labelFont = UIFont(name: "HelveticaNeue-Light", size: 10)!
        volumeView.leftAxis.drawBottomYLabelEntryEnabled = false
        volumeView.leftAxis.drawZeroLineEnabled = false
        volumeView.leftAxis.setLabelCount(1, force: true)
        volumeView.leftAxis.valueFormatter = volumeChartFormatter
    }
    
    override func updateChartData() {
        if self.shouldHideData {
            chartView.data = nil
            return
        }
        
        if (!chartData.isEmpty) {
            setChartsData(chartData: chartData)
        }
    }
    
    func setChartsData(chartData:[Candle]){
        self.chartData = chartData
        if timeInterval == Constants.TimeIntervals.day {
            self.chartData = shrinkMinuteDataToTenMinutes(chartData)
        }
        
        priceChartFormatter.resetXAxisLabels()
        let yVals1 = self.chartData.enumerated().map { (index: Int, candle:Candle) -> CandleChartDataEntry in
            let high = candle.high
            let low = candle.low
            let open = candle.open
            let close = candle.close
            priceChartFormatter.addXAxisLabel(candle.datetime)
            return CandleChartDataEntry(x: Double(index), shadowH: high, shadowL: low, open: open, close: close)
        }
        let set1 = CandleChartDataSet(values: yVals1, label: "Price")
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
        
        volumeChartFormatter.resetAxisLabels()
        let yVals2 = self.chartData.enumerated().map { (index: Int, candle:Candle) -> BarChartDataEntry in
            volumeChartFormatter.addAxisLabel(candle.volume)
            return BarChartDataEntry(x: Double(index), y: candle.volume)
        }
        let set2 = BarChartDataSet(values: yVals2, label: "Volume")
        set2.setColor(Constants.purple)
        
        let priceData = CandleChartData(dataSet: set1)
        let volumeData = BarChartData(dataSet: set2)
        DispatchQueue.main.async {
            self.chartView.data = priceData
            self.chartView.candleData?.setDrawValues(false)
        
            self.volumeView.data = volumeData
            self.volumeView.data?.setDrawValues(false)
        }
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
        let volumeString = NumberFormatter.formatNumber(num: candle.volume)
        candlePricesView.volumeLabel.text = "VOL: " + volumeString
        candlePricesView.highLabel.text = "HIGH: " + String(format: "%.2f", e.high)
        candlePricesView.lowLabel.text = "LOW: " + String(format: "%.2f", e.low)
        candlePricesView.openLabel.text = "OPEN: " + String(format: "%.2f", e.open)
        candlePricesView.closeLabel.text = "CLOSE: " + String(format: "%.2f", e.close)
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
        
        setTopBarValues(startPrice: chartData[0].close, endPrice: candle.close, selected: true)
        feedbackGenerator.selectionChanged()
    }
    
    private func moveMarkerView(_ xPos: CGFloat){
        var x:CGFloat = 0.0
        if xPos + (markerView.bounds.width/2) > chartView.bounds.width {
            x = chartView.bounds.width - (markerView.bounds.width/2)
        }
        if xPos - (markerView.bounds.width/2) < 0 {
            x = (markerView.bounds.width/2)
        }
        markerView.center = CGPoint(x: x, y:10.0)
    }
    
    override func chartValueNothingSelected(_ chartView: ChartViewBase) {
        candlePricesWrapper.isHidden = true
        markerView.isHidden = true
        chartView.highlightValue(nil)
        setTopBarValues(startPrice: chartData[0].close, endPrice: latestQuote.latestPrice, selected: false)
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //CANDLE: combines 1-minute candles into 10-minute candles
    private func shrinkMinuteDataToTenMinutes(_ chartData: [Candle]) -> [Candle]{
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
        return dataSet
    }
    
    @IBAction func chartModeButtonPressed(_ sender: Any) {
        if candleMode {
            chartTypeButton.setImage(UIImage(named: "candlebar.png"), for: .normal)
        } else {
            chartTypeButton.setImage(UIImage(named: "linechart.png"), for: .normal)
        }
        candleMode = !candleMode
    }
    
    override func panGestureEnded(_ chartView: ChartViewBase) {
        self.chartValueNothingSelected(chartView)
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
    
    @IBOutlet weak var button1D: UIButton!
    @IBOutlet weak var button1M: UIButton!
    @IBOutlet weak var button3M: UIButton!
    @IBOutlet weak var button6M: UIButton!
    @IBOutlet weak var button1Y: UIButton!
    @IBOutlet weak var button5Y: UIButton!
    
    @IBAction func OneDayButtonPressed(_ sender: Any) {
        self.timeButtonPressed(sender as! UIButton, chartData: company.minuteData, timeInterval: Constants.TimeIntervals.day)
    }
    
    @IBAction func OneMonthButtonPressed(_ sender: Any) {
        self.timeButtonPressed(sender as! UIButton, chartData: company.getDailyData(25), timeInterval: Constants.TimeIntervals.one_month)
    }
    
    @IBAction func ThreeMonthsButtonPressed(_ sender: Any) {
        self.timeButtonPressed(sender as! UIButton, chartData: company.getDailyData(75), timeInterval: Constants.TimeIntervals.three_month)
    }
    
    @IBAction func SixMonthsButtonPressed(_ sender: Any) {
        self.timeButtonPressed(sender as! UIButton, chartData: company.getDailyData(150), timeInterval: Constants.TimeIntervals.six_month)
    }
    
    @IBAction func OneYearButtonPressed(_ sender: Any) {
        self.timeButtonPressed(sender as! UIButton, chartData: company.getDailyData(300), timeInterval: Constants.TimeIntervals.one_year)
    }
    
    @IBAction func FiveYearButtonPressed(_ sender: Any) {
        self.chartData = company.getDailyData(1500)
        self.timeInterval = Constants.TimeIntervals.five_year
        self.timeButtonPressed(sender as! UIButton, chartData: company.getDailyData(1500), timeInterval: Constants.TimeIntervals.five_year)
    }
    
    private func timeButtonPressed(_ button: UIButton, chartData: [Candle], timeInterval: Constants.TimeIntervals){
        
        self.chartData = chartData
        self.timeInterval = timeInterval
        setTopBarValues(startPrice: chartData[0].close, endPrice: latestQuote.latestPrice, selected: false)
        
        for timeButton in timeButtons {
            if timeButton == button {
                timeButton.backgroundColor = UIColor.white
                timeButton.setTitleColor(Constants.darkGrey, for: .normal)
            } else {
                timeButton.backgroundColor = Constants.darkPink
                timeButton.setTitleColor(UIColor.white, for: .normal)
            }
        }
        self.updateChartData()
    }
    
}

extension StockDetailsVC: StatsNewsPageViewControllerDelegate {
    func pageViewController(pageViewController: UIPageViewController, didUpdatePageCount count: Int) {
        pageControl.numberOfPages = count
    }
    
    func pageViewController(pageViewController: StatsNewsPageViewController, didUpdatePageIndex index: Int) {
        pageControl.currentPage = index
    }
}
