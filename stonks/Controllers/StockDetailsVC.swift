//
//  StockDetailsVC.swift
//  stonks
//
//  Created by Samuel Hobel on 10/9/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import UIKit
import Charts
import Parchment
import MaterialActivityIndicator
import RSLoadingView

class StockDetailsVC: DemoBaseViewController, Updateable {

    @IBOutlet weak var stockDetailsNavView: StockDetailsNavView!
    @IBOutlet weak var priceDetailsView: StockDetailsSummaryView!
    @IBOutlet weak var chartView: CustomCombinedChartView!
    @IBOutlet weak var volumeView: BarChartView!
    @IBOutlet weak var candlePricesWrapper: UIView!
    @IBOutlet weak var candlePricesView: CandlePricesView!
    @IBOutlet weak var candleMarkerView: MarkerView!
    @IBOutlet weak var chartTypeButton: UIButton!
    
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    
    @IBOutlet weak var datetime: UILabel!
    @IBOutlet weak var ytdChange: ColoredValueLabel!
    @IBOutlet weak var yrHighValue: ColoredValueLabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var innerScroll: UIView!
    @IBOutlet weak var chartTimeView: UIStackView!
    @IBOutlet weak var chartViewWrapperHeightConstraint: NSLayoutConstraint!
    
    private var company:Company!
    private var latestQuote:Quote!
    private var isMarketOpen:Bool = true
    private var priceChartFormatter:PriceChartFormatter!
    private var volumeChartFormatter:VolumeChartFormatter!
    
    private var feedbackGenerator: UISelectionFeedbackGenerator!
    public var candleMode = false
    public var timeInterval = Constants.TimeIntervals.day
    private var timeButtons:[UIButton]!
    
    private var alphaVantage = AlphaVantage()
    
    private let loadingView = RSLoadingView()
    private var handlersDone = 0
    private var totalHandlers = 13
    
    private var pageVCList:[UIViewController] = []
    private var keyStatsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StatsVC")
    private var advancedStatsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AdvancedVC")
    private var newsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewsVC")
    private var earningsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EarningsVC")
    private var financialsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FinVC")
    private var predictionsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PredictionsVC")
    private var companyVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InfoVC")
    
    private var stockUpdater:StockUpdater?
    
    fileprivate let icons = [
        "stats",
        "news",
        "advanced",
        "financials",
        "earnings",
        "analysts",
        "company"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateChartHeight()

        company = Dataholder.watchlistManager.selectedCompany
        //let pageVC: StatsNewsPageViewController = self.children.first as! StatsNewsPageViewController
        //pageVC.pageDelegate = self
        
        self.stockUpdater = StockUpdater(caller: self, ticker: company.symbol)
        self.stockUpdater?.startTask()
        
        self.pageVCList = [
            self.keyStatsVC, self.newsVC, self.advancedStatsVC, self.financialsVC, self.earningsVC, self.predictionsVC, self.companyVC
        ]
        
        let pageVC = PagingViewController<IconItem>()
        pageVC.menuItemSource = .class(type: IconPagingCell.self)
        pageVC.menuHorizontalAlignment = .center
        pageVC.menuItemSize = .sizeToFit(minWidth: 60, height: 60)
        pageVC.menuBackgroundColor = UIColor(red: 239.0/255.0, green: 239.0/255.0, blue: 244.0/255.0, alpha: 1)
        pageVC.indicatorColor = Constants.darkPink
        pageVC.dataSource = self
        pageVC.select(pagingItem: IconItem(icon: icons[0], index: 0))
        
        self.addChild(pageVC)
        self.scrollView.addSubview(pageVC.view)
        pageVC.didMove(toParent: self)
        pageVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            pageVC.view.topAnchor.constraint(equalTo: chartTimeView.bottomAnchor)
        ])
        pageVC.selectedFont = UIFont(name: "HelveticaNeue-Thin", size: 12.0)!
        pageVC.backgroundColor = UIColor.lightGray
        
        volumeView.delegate = self
        /* We have a custom nav panel and so the default one goes on the bottom for some reason
         and then our tab bar at the bottom gets darker */
        self.navigationController?.view.backgroundColor = UIColor.white
        
        chartTypeButton.imageView!.contentMode = UIView.ContentMode.scaleAspectFit
        feedbackGenerator = UISelectionFeedbackGenerator()
        
        //setup general stock and price information
        stockDetailsNavView.logo.layer.cornerRadius = (stockDetailsNavView.logo.frame.width)/2
        stockDetailsNavView.logo.layer.masksToBounds = true
        stockDetailsNavView.ticker.text = company.symbol
        stockDetailsNavView.name.text = company.fullName
        
        latestQuote = company.quote
        //setup price info that will need to be updated each time quote is retreived
        if (latestQuote != nil){
            setTopBarValues(startPrice: 0.0, endPrice: latestQuote.latestPrice!, selected: false)
        }
        
        //load charts
        setGlobalChartOptions()
        volumeChartFormatter = VolumeChartFormatter()
        loadVolumeChart() //volume chart has to be setup before main chart
        self.chartView.setup(delegate: self, volumeView: self.volumeView)
        
        //loading indicator setup
        self.loadingView.dimBackgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.loadingView.speedFactor = 1.5
        self.loadingView.sizeInContainer = CGSize(width: 100, height: 100)
        self.loadingView.showOnKeyWindow()
        
        //start information retrieval processes
        StockAPIManager.shared.stockDataApiInstance.getCompanyGeneralInfo(ticker: company.symbol, completionHandler: handleCompanyData)
        if !Constants.locked {
            StockAPIManager.shared.stockDataApiInstance.getKeyStats(ticker: company.symbol, completionHandler: handleKeyStats)
            StockAPIManager.shared.stockDataApiInstance.getAdvancedStats(ticker: company.symbol, completionHandler: handleAdvancedStats)
            StockAPIManager.shared.stockDataApiInstance.getNews(ticker: company.symbol, completionHandler: handleNews)
            StockAPIManager.shared.stockDataApiInstance.getPriceTarget(ticker: company.symbol, completionHandler: handlePriceTarget)
            StockAPIManager.shared.stockDataApiInstance.getRecommendations(ticker: company.symbol, completionHandler: handleRecommendations)
            StockAPIManager.shared.stockDataApiInstance.getFinancials(ticker: company.symbol, completionHandler: handleFinancials)
            StockAPIManager.shared.stockDataApiInstance.getEstimates(ticker: company.symbol, completionHandler: handleEstimates)
            StockAPIManager.shared.stockDataApiInstance.getEarnings(ticker: company.symbol, completionHandler: handleEarnings)
        }
        
        self.alphaVantage.getDailyChart(ticker: company.symbol, timeInterval: Constants.TimeIntervals.twenty_year, completionHandler: handleDailyChartData)
        self.alphaVantage.getWeeklyChart(ticker: company.symbol, timeInterval: Constants.TimeIntervals.twenty_year, completionHandler: handleWeeklyChartData)
        self.alphaVantage.getMonthlyChart(ticker: company.symbol, timeInterval: Constants.TimeIntervals.twenty_year, completionHandler: handleMonthlyChartData)
        
        //StockAPIManager.shared.stockDataApiInstance.getDailyChart(ticker: company.symbol, timeInterval: .max, completionHandler: handleFullChartData)
        
        //setup chart buttons
        timeButtons = [button1D, button1M, button3M, button1Y, button5Y, buttonMax]
        button1D.backgroundColor = UIColor.white
        button1D.setTitleColor(Constants.darkGrey, for: .normal)
        timeInterval = Constants.TimeIntervals.day
    }
    
    func updateFromScheduledTask(_ data:Any?) {
        let quotes = data as! [Quote]
        if (quotes.count > 0){
            let quote = quotes[0]
            self.latestQuote = quote
            DispatchQueue.main.async {
                self.setTopBarValues(startPrice: 0.0, endPrice: self.latestQuote.latestPrice!, selected: false)
            }
            self.isMarketOpen = quote.isUSMarketOpen!
            StockAPIManager.shared.stockDataApiInstance.getDailyChart(ticker: company.symbol, timeInterval: .day, completionHandler: handleDayChartData)
            if !self.isMarketOpen {
                self.stockUpdater?.stopTask()
            }
        }
    }
    
    private func incrementLoadingProgress(){
        self.handlersDone+=1
        let total = Constants.locked ? self.totalHandlers - 8 : self.totalHandlers
        if (self.handlersDone >= total){
            DispatchQueue.main.async {
                print("hiding view")
                self.loadingView.hide()
            }
        }
    }
    
    private func updateChartHeight(){
        let h = self.view.frame.height - self.chartView.frame.height
        let diff = h - 650
        if (diff > 0 && diff < 300){
            self.chartViewWrapperHeightConstraint.constant = diff
            self.view.layoutIfNeeded()
        }  
    }
    
    //when receving new quote, call this to update top bar values
    private func setTopBarValues(startPrice: Double, endPrice: Double, selected: Bool){
        priceDetailsView.priceLabel.text = String(format: "%.2f", endPrice)
        
        if timeInterval == Constants.TimeIntervals.day && !selected {
            priceDetailsView.priceChangeAndPercent.setPriceChange(price: latestQuote.change!, percent: latestQuote.changePercent!)
        } else {
            let priceChange = endPrice - startPrice
            let percentChange = (priceChange / startPrice)
            priceDetailsView.priceChangeAndPercent.setPriceChange(price: priceChange, percent: percentChange)
        }
        
        if latestQuote.latestTime!.contains(":"){
            datetime.text = latestQuote.latestTime! + " ET"
        } else {
            datetime.text = latestQuote.latestTime
        }
        ytdChange.setValue(value: latestQuote.ytdChange!, isPercent: true)
        yrHighValue.setValue(value: latestQuote.getYrHighChangePercent(), isPercent: true)
    }
    
    //handles the description, ceo, and logo
    private func handleCompanyData(_ generalInfo: GeneralInfo, logo: String){
        self.company.generalInfo = generalInfo
        self.company.logo = logo
        let url = URL(string: logo)
        let data = try? Data(contentsOf: url!)
        
        if let imageData = data {
            updateUI {
                self.stockDetailsNavView.logo.contentMode = .scaleAspectFit
                self.stockDetailsNavView.logo.image = UIImage(data: imageData)
            }
        }
        let x = self.companyVC as! StatsVC
        x.updateData()
        
        print("\(self.handlersDone) company data done")
        self.incrementLoadingProgress()
    }
    
    private func handleDayChartData(_ chartData:[Candle]){
        if chartData.isEmpty {
            let date = ""
            //get most recent date from company.dailyData
            StockAPIManager.shared.stockDataApiInstance.getChartForDate(ticker: company.symbol, date: date, completionHandler: handleDayChartData(_:))
        } else {
            company.setMinuteData(chartData, open: self.isMarketOpen)
            if self.timeInterval == Constants.TimeIntervals.day {
                self.chartView.setChartData(chartData: company.minuteData)
            }
            print("\(self.handlersDone) day chart done")
            self.incrementLoadingProgress()
        }
    }

    private func handleDailyChartData(_ chartData:[Candle]){
        if chartData.isEmpty {
            self.alphaVantage.getDailyChart(ticker: self.company.symbol, timeInterval: Constants.TimeIntervals.twenty_year, completionHandler: handleDayChartData)
        } else {
            company.dailyData = chartData.sorted{
                guard let d1 = $0.date, let d2 = $1.date else { return false }
                return d1 < d2
            }
            print("\(self.handlersDone) daily chart done")
            self.incrementLoadingProgress()
        }
    }
   
    private func handleWeeklyChartData(_ chartData:[Candle]){
        if chartData.isEmpty {
            self.alphaVantage.getWeeklyChart(ticker: self.company.symbol, timeInterval: Constants.TimeIntervals.twenty_year, completionHandler: handleWeeklyChartData)
        } else {
            company.weeklyData = chartData.sorted{
                guard let d1 = $0.date, let d2 = $1.date else { return false }
                return d1 < d2
            }
            self.incrementLoadingProgress()
            print("\(self.handlersDone) weekly chart done")
        }
    }
    
    private func handleMonthlyChartData(_ chartData:[Candle]){
        if chartData.isEmpty {
            self.alphaVantage.getMonthlyChart(ticker: self.company.symbol, timeInterval: Constants.TimeIntervals.twenty_year, completionHandler: handleMonthlyChartData)
        } else {
            company.monthlyData = chartData.sorted{
                guard let d1 = $0.date, let d2 = $1.date else { return false }
                return d1 < d2
            }
            self.incrementLoadingProgress()
            print("\(self.handlersDone) monthly chart done")
        }
    }
    
    //unused
    private func handleFullChartData(_ chartData:[Candle]){

    }
    
    public func updateUI(function: @escaping ()->Void){
        DispatchQueue.main.async {
            function()
        }
    }
    
    func setGlobalChartOptions(){
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
        self.chartView.updateChart() //necessary?
    }
    
    override func optionTapped(_ option: Option) {
        switch option {
        case .toggleShadowColorSameAsCandle:
            for set in chartView.data!.dataSets as! [CandleChartDataSet] {
                set.shadowColorSameAsCandle = !set.shadowColorSameAsCandle
            }
            chartView.notifyDataSetChanged()
        case .toggleShowCandleBar:
            if self.candleMode {
                self.chartView.showCandleChart()
            } else {
                self.chartView.showLineChart()
            }
        default:
            super.handleOption(option, forChartView: chartView)
        }
    }
    
    override func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        let chartData = self.chartView.getChartData(candleMode: self.candleMode)
        if (chartData.count <= Int(entry.x)){
            return
        }
        let candle = chartData[Int(entry.x)]
        let volumeString = NumberFormatter.formatNumber(num: candle.volume!)
        candlePricesView.volumeLabel.text = "VOLUME: " + volumeString
        candlePricesView.highLabel.text = "HI: " + String(format: "%.2f", candle.high!)
        candlePricesView.lowLabel.text = "LO: " + String(format: "%.2f", candle.low!)
        candlePricesView.openLabel.text = "OPEN: " + String(format: "%.2f", candle.open!)
        candlePricesView.closeLabel.text = "CLOSE: " + String(format: "%.2f", candle.close!)
        candlePricesWrapper.isHidden = false
        
        // Adding top marker
        candleMarkerView.dateLabel.text = "\(candle.datetime!)"
        var x = highlight.xPx.rounded()
        if x+(candleMarkerView.bounds.width/2) > chartView.bounds.width {
            x = chartView.bounds.width - (candleMarkerView.bounds.width/2)
        }
        if x-(candleMarkerView.bounds.width/2) < 0 {
            x = (candleMarkerView.bounds.width/2)
        }
        candleMarkerView.center = CGPoint(x: x, y:10.0)
        candleMarkerView.isHidden = false
        
        setTopBarValues(startPrice: chartData[0].close!, endPrice: candle.close!, selected: true)
        feedbackGenerator.selectionChanged()
    }
    
    private func moveMarkerView(_ xPos: CGFloat){
        var x:CGFloat = 0.0
        if xPos + (candleMarkerView.bounds.width/2) > chartView.bounds.width {
            x = chartView.bounds.width - (candleMarkerView.bounds.width/2)
        }
        if xPos - (candleMarkerView.bounds.width/2) < 0 {
            x = (candleMarkerView.bounds.width/2)
        }
        candleMarkerView.center = CGPoint(x: x, y:10.0)
    }
    
    override func chartValueNothingSelected(_ chartView: ChartViewBase) {
        candlePricesWrapper.isHidden = true
        candleMarkerView.isHidden = true
        chartView.highlightValue(nil)
        let chartData = self.chartView.getChartData(candleMode: self.candleMode)
        setTopBarValues(startPrice: chartData[0].close!, endPrice: latestQuote.latestPrice!, selected: false)
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func chartModeButtonPressed(_ sender: Any) {
        candleMode = !candleMode
        if !candleMode {
            self.optionTapped(.toggleShowCandleBar)
            chartTypeButton.setImage(UIImage(named: "candlebar_white.png"), for: .normal)
        } else {
            self.optionTapped(.toggleShowCandleBar)
            chartTypeButton.setImage(UIImage(named: "linechart_white.png"), for: .normal)
        }
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
    @IBOutlet weak var buttonMax: UIButton!
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
    
    @IBAction func TwentyYearButtonPressed(_ sender: Any) {
        self.timeButtonPressed(sender as! UIButton, chartData: company.getQuarterlyData(80), timeInterval: Constants.TimeIntervals.twenty_year)
    }
    
    @IBAction func OneYearButtonPressed(_ sender: Any) {
        self.timeButtonPressed(sender as! UIButton, chartData: company.getWeeklyData(52), timeInterval: Constants.TimeIntervals.one_year)
    }
    
    @IBAction func FiveYearButtonPressed(_ sender: Any) {
        //self.chartData = company.getDailyData(1500)
        self.timeInterval = Constants.TimeIntervals.five_year
        self.timeButtonPressed(sender as! UIButton, chartData: company.getMonthlyData(60), timeInterval: Constants.TimeIntervals.five_year)
    }
    
    private func timeButtonPressed(_ button: UIButton, chartData: [Candle], timeInterval: Constants.TimeIntervals){
        self.timeInterval = timeInterval
        setTopBarValues(startPrice: chartData[0].close!, endPrice: latestQuote.latestPrice!, selected: false)
        
        for timeButton in timeButtons {
            if timeButton == button {
                timeButton.backgroundColor = UIColor.white
                timeButton.setTitleColor(Constants.darkGrey, for: .normal)
            } else {
                timeButton.backgroundColor = Constants.darkPink
                timeButton.setTitleColor(UIColor.white, for: .normal)
            }
        }
        self.chartView.setChartData(chartData: chartData)
        self.chartValueNothingSelected(self.chartView)
    }
    
    //data saving functions
    private func handleKeyStats(keyStats: KeyStats){
        self.company.keyStats = keyStats
        let x = self.keyStatsVC as! StatsVC
        x.updateData()
        print("\(self.handlersDone) key stats done")
        self.incrementLoadingProgress()
    }
    
    private func handleNews(news: [News]){
        self.company.news = news
        let x = self.newsVC as! StatsVC
        x.updateData()
        print("\(self.handlersDone) news done")
        self.incrementLoadingProgress()
    }
    
    private func handleAdvancedStats(advancedStats: AdvancedStats){
        self.company.advancedStats = advancedStats
        let x = self.advancedStatsVC as! StatsVC
        x.updateData()
        print("\(self.handlersDone) advanced done")
        self.incrementLoadingProgress()
    }
    
    private func handlePriceTarget(priceTarget: PriceTarget){
        self.company.priceTarget = priceTarget
        let x = self.predictionsVC as! StatsVC
        x.updateData()
        print("\(self.handlersDone) price targets done")
        self.incrementLoadingProgress()
    }
    
    private func handleRecommendations(recommendations: [Recommendations]){
        self.company.recommendations = recommendations
        let x = self.predictionsVC as! StatsVC
        x.updateData()
        print("\(self.handlersDone) recommendations done")
        self.incrementLoadingProgress()
    }
    
    private func handleFinancials(financials: Financials){
        self.company.financials = financials
        let x = self.financialsVC as! StatsVC
        x.updateData()
        print("\(self.handlersDone) financials done")
        self.incrementLoadingProgress()
    }
    
    private func handleEstimates(estimates: Estimates){
        self.company.estimates = estimates
        let x = self.predictionsVC as! StatsVC
        x.updateData()
        print("\(self.handlersDone) estimates done")
        self.incrementLoadingProgress()
    }
    
    private func handleEarnings(earnings: [Earnings]){
        self.company.earnings = earnings
        let x = self.earningsVC as! StatsVC
        x.updateData()
        print("\(self.handlersDone) earnings done")
        self.incrementLoadingProgress()
    }
    
}

extension StockDetailsVC: PagingViewControllerDataSource {
    
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, viewControllerForIndex index: Int) -> UIViewController {
        return self.pageVCList[index]
    }
    
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, pagingItemForIndex index: Int) -> T {
        return IconItem(icon: icons[index], index: index) as! T
    }
    
    func numberOfViewControllers<T>(in: PagingViewController<T>) -> Int {
        return self.pageVCList.count
    }
}
