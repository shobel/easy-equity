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

class StockDetailsVC: DemoBaseViewController, Updateable {

    @IBOutlet weak var stockDetailsNavView: StockDetailsNavView!
    @IBOutlet weak var priceDetailsView: StockDetailsSummaryView!
    @IBOutlet weak var chartView: CustomCombinedChartView!
    @IBOutlet weak var candlePricesWrapper: UIView!
    @IBOutlet weak var candlePricesView: CandlePricesView!
    @IBOutlet weak var candleMarkerView: MarkerView!
    @IBOutlet weak var chartTypeButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var datetime: UILabel!
    @IBOutlet weak var totalVol: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var innerScroll: UIView!
    @IBOutlet weak var chartTimeView: UIStackView!
    @IBOutlet weak var pagingView: UIView!
    @IBOutlet weak var chartViewWrapperHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var timeViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pagingViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var loaderView: UIView!
    @IBOutlet weak var watchlistButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    public var company:Company!
    public var latestQuote:Quote!
    private var isMarketOpen:Bool = true
    private var priceChartFormatter:PriceChartFormatter!
    private var volumeChartFormatter:VolumeChartFormatter!
    
    private var feedbackGenerator: UISelectionFeedbackGenerator!
    public var candleMode = false
    public var timeInterval = Constants.TimeIntervals.day
    private var timeButtons:[UIButton]!
    
    private var alphaVantage = AlphaVantage()
    
    private var handlersDone = 0
    private var totalHandlers = 0
    
    private var pageVCList:[UIViewController] = []
    private var keyStatsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StatsVC")
    private var newsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewsVC") as! NewsTableViewController
    private var earningsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EarningsVC")
    private var financialsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FinVC")
    private var predictionsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PredictionsVC")
    private var companyVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InfoVC")
    
    private var stockUpdater:StockUpdater?
    private var pageVC: PagingViewController!
    
    fileprivate let icons = [
        "stats",
        "news",
        "financials",
        "earnings",
        "analysts",
        "company"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateChartHeight()

        company = Dataholder.selectedCompany
        //let pageVC: StatsNewsPageViewController = self.children.first as! StatsNewsPageViewController
        //pageVC.pageDelegate = self
        
        self.stockUpdater = StockUpdater(caller: self, ticker: company.symbol, timeInterval: 10.0)
        self.stockUpdater?.startTask()
        
        self.pageVCList = [
            self.keyStatsVC, self.newsVC, self.financialsVC, self.earningsVC, self.predictionsVC, self.companyVC
        ]
        
        pageVC = PagingViewController()
        pageVC.register(IconPagingCell.self, for: IconItem.self)
        pageVC.menuHorizontalAlignment = .center
        pageVC.menuItemSize = .sizeToFit(minWidth: 60, height: 60)
        pageVC.menuBackgroundColor = UIColor(red: 239.0/255.0, green: 239.0/255.0, blue: 244.0/255.0, alpha: 1)
        pageVC.indicatorColor = Constants.darkPink
        pageVC.dataSource = self
        pageVC.delegate = self
        pageVC.select(pagingItem: IconItem(icon: icons[0], index: 0))
        
        self.addChild(pageVC)
        self.pagingView.addSubview(pageVC.view)
        pageVC.didMove(toParent: self)
        pageVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageVC.view.leadingAnchor.constraint(equalTo: pagingView.leadingAnchor),
            pageVC.view.trailingAnchor.constraint(equalTo: pagingView.trailingAnchor),
            //pageVC.view.bottomAnchor.constraint(equalTo: pagingView.bottomAnchor),
            self.pagingView.bottomAnchor.constraint(equalTo: pageVC.view.bottomAnchor),
            pageVC.view.topAnchor.constraint(equalTo: pagingView.topAnchor)
        ])
        pageVC.selectedFont = UIFont(name: "HelveticaNeue-Thin", size: 12.0)!
        pageVC.backgroundColor = UIColor.lightGray
        
        /* We have a custom nav panel and so the default one goes on the bottom for some reason
         and then our tab bar at the bottom gets darker */
        //self.navigationController?.view.backgroundColor = UIColor.white

        chartTypeButton.imageView!.contentMode = UIView.ContentMode.scaleAspectFit
        feedbackGenerator = UISelectionFeedbackGenerator()
        
        //watchlist button
        if Dataholder.watchlistManager.getWatchlist().contains(company){
            self.addedToWatchlist(true)
        } else {
            self.addedToWatchlist(false)
        }
        
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
        self.chartView.setup(delegate: self)
        self.chartView.delegate = self
        
        //loader indicator setup
        self.loaderView.isHidden = false
        self.activityIndicator.startAnimating()
        
        //start information retrieval processes
        self.totalHandlers = 12
//        StockAPIManager.shared.stockDataApiInstance.getCompanyGeneralInfo(ticker: company.symbol, completionHandler: handleCompanyData)
        if !Constants.locked {
//            StockAPIManager.shared.stockDataApiInstance.getKeyStats(ticker: company.symbol, completionHandler: handleKeyStats)
//            StockAPIManager.shared.stockDataApiInstance.getAdvancedStats(ticker: company.symbol, completionHandler: handleAdvancedStats)
//            StockAPIManager.shared.stockDataApiInstance.getNews(ticker: company.symbol, completionHandler: handleNews)
//            StockAPIManager.shared.stockDataApiInstance.getPriceTarget(ticker: company.symbol, completionHandler: handlePriceTarget)
//            StockAPIManager.shared.stockDataApiInstance.getRecommendations(ticker: company.symbol, completionHandler: handleRecommendations)
//            StockAPIManager.shared.stockDataApiInstance.getFinancials(ticker: company.symbol, completionHandler: handleFinancials)
//            StockAPIManager.shared.stockDataApiInstance.getEstimates(ticker: company.symbol, completionHandler: handleEstimates)
//            StockAPIManager.shared.stockDataApiInstance.getEarnings(ticker: company.symbol, completionHandler: handleEarnings)
            StockAPIManager.shared.stockDataApiInstance.getAllData(ticker: company.symbol, completionHandler: handleAllData)
//            self.alphaVantage.getMovingAverage(ticker: company.symbol, range: "50", completionHandler: handleSMA50)
//            self.alphaVantage.getMovingAverage(ticker: company.symbol, range: "100", completionHandler: handleSMA100)
//            self.alphaVantage.getMovingAverage(ticker: company.symbol, range: "200", completionHandler: handleSMA200)
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
        
        self.adjustContentHeight(vc: self.keyStatsVC)
        
    }
    
    func updateFromScheduledTask(_ data:Any?) {
        let quotes = data as! [Quote]
        if (quotes.count > 0){
            let quote = quotes[0]
            self.latestQuote = quote
            self.setVolumeValues(averageVolume: Double(quote.avgTotalVolume ?? 0), totalVol: Double(quote.latestVolume ?? 0))
            DispatchQueue.main.async {
                self.setTopBarValues(startPrice: 0.0, endPrice: self.latestQuote.latestPrice!, selected: false)
            }
            self.isMarketOpen = quote.isUSMarketOpen!
            StockAPIManager.shared.stockDataApiInstance.getDailyChart(ticker: company.symbol, timeInterval: .day, completionHandler: handleDayChartNoProgress)
            if !self.isMarketOpen {
                self.stockUpdater?.stopTask()
            }
        }
    }
    
    private func incrementLoadingProgress(){
        self.handlersDone+=1
        let total = self.totalHandlers
        if (self.handlersDone >= total){
            self.adjustContentHeight(vc: self.keyStatsVC)
            self.company.addSmaToCandleSets(smaSet: self.company.sma50, key: "50")
            self.company.addSmaToCandleSets(smaSet: self.company.sma100, key: "100")
            self.company.addSmaToCandleSets(smaSet: self.company.sma200, key: "200")
            DispatchQueue.main.async {
                self.loaderView.isHidden = true
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
    
    @IBAction func watchlistButtonTapped(_ sender: Any) {
        self.hideLoader(false)
        if (Dataholder.watchlistManager.getWatchlist().contains(self.company)) {
            Dataholder.watchlistManager.removeCompany(company: self.company){
                self.addedToWatchlist(false)
                self.hideLoader(true)
            }
        } else {
            Dataholder.watchlistManager.addCompany(company: self.company){
                self.addedToWatchlist(true)
                self.hideLoader(true)
            }
        }
    }
    
    public func hideLoader(_ hide:Bool){
        DispatchQueue.main.async {
            self.loaderView.isHidden = hide
        }
    }
    
    public func addedToWatchlist(_ added:Bool) {
        DispatchQueue.main.async {
            if added {
                self.watchlistButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
                self.watchlistButton.tintColor = Constants.darkPink
            } else {
                self.watchlistButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
                self.watchlistButton.tintColor = Constants.darkGrey
            }
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
    }
    
    //SAM-TODO remove average volume argument and encorporate low volume into analysis as a negative trait
    public func setVolumeValues(averageVolume:Double, totalVol:Double){
        DispatchQueue.main.async {
            self.totalVol.text = String("VOLUME \(NumberFormatter.formatNumber(num: totalVol))")
        }
    }
    
    private func handleAllData(generalInfo: GeneralInfo, logo: String, keystats: KeyStats, news: [News], priceTarget: PriceTarget, earnings: [Earnings], recommendations: [Recommendations], advancedStats: AdvancedStats, financials: Financials, estimates: Estimates){
        self.handleCompanyData(generalInfo, logo: logo)
        self.handleKeyStats(keyStats: keystats)
        self.handleNews(news: news)
        self.handlePriceTarget(priceTarget: priceTarget)
        self.handleEarnings(earnings: earnings)
        self.handleRecommendations(recommendations: recommendations)
        self.handleAdvancedStats(advancedStats: advancedStats)
        self.handleFinancials(financials: financials)
        self.handleEstimates(estimates: estimates)
    }
    
    private func handleSMA200(_ smaData:[DatedValue]){
        if smaData.isEmpty {
            self.alphaVantage.getMovingAverage(ticker: company.symbol, range: "20", completionHandler: handleSMA200)
        } else {
            self.company.sma200 = smaData.sorted{
                guard let d1 = $0.date, let d2 = $1.date else { return false }
                return d1 < d2
            }
            self.incrementLoadingProgress()
        }
    }
    
    private func handleSMA50(_ smaData:[DatedValue]){
        if smaData.isEmpty {
            self.alphaVantage.getMovingAverage(ticker: company.symbol, range: "50", completionHandler: handleSMA50)
        } else {
            self.company.sma50 = smaData.sorted{
                guard let d1 = $0.date, let d2 = $1.date else { return false }
                return d1 < d2
            }
            self.incrementLoadingProgress()
        }
    }
    
    private func handleSMA100(_ smaData:[DatedValue]){
        if smaData.isEmpty {
            self.alphaVantage.getMovingAverage(ticker: company.symbol, range: "100", completionHandler: handleSMA100)
        } else {
            self.company.sma100 = smaData.sorted{
                guard let d1 = $0.date, let d2 = $1.date else { return false }
                return d1 < d2
            }
            self.incrementLoadingProgress()
        }
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
    
    private func adjustContentHeight(vc: UIViewController){
        DispatchQueue.main.async{
            let statsVC = vc as! StatsVC
            self.pagingViewHeightConstraint.constant = statsVC.getContentHeight() + 80
        }
    }
    
    private func handleDayChartNoProgress(_ chartData:[Candle]){
        self.handleDayChartMain(chartData, updateProgress: false)
    }
    
    private func handleDayChartData(_ chartData:[Candle]){
        self.handleDayChartMain(chartData, updateProgress: true)
    }
    
    private func handleDayChartMain(_ chartData:[Candle], updateProgress: Bool){
        if chartData.isEmpty {
            let date = ""
            StockAPIManager.shared.stockDataApiInstance.getChartForDate(ticker: company.symbol, date: date, completionHandler: handleDayChartData(_:))
        } else {
            company.setMinuteData(chartData, open: self.isMarketOpen)
            if self.timeInterval == Constants.TimeIntervals.day {
                self.chartView.setChartData(chartData: company.minuteData)
            }
            print("\(self.handlersDone) day chart done")
            if updateProgress {
                self.incrementLoadingProgress()
            }
        }
    }

    private func handleDailyChartData(_ chartData:[Candle]){
        if chartData.isEmpty {
            self.alphaVantage.getDailyChart(ticker: self.company.symbol, timeInterval: Constants.TimeIntervals.twenty_year, completionHandler: handleDailyChartData)
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
        scrollView.isScrollEnabled = false
        let cv = chartView as! CustomCombinedChartView
        cv.hideAxisLabels(hideEarnings: self.timeInterval != Constants.TimeIntervals.day)
        let chartData = self.chartView.getChartData(candleMode: self.candleMode)
        if (chartData.count <= Int(entry.x)){
            return
        }
        let candle = chartData[Int(entry.x)]
        let volumeString = NumberFormatter.formatNumber(num: candle.volume!)
        candlePricesView.volumeLabel.text = "VOL: " + volumeString
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
        
        setTopBarValues(startPrice: latestQuote.previousClose ?? chartData[0].close!, endPrice: candle.close!, selected: true)
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
        scrollView.isScrollEnabled = true
        let cv = chartView as! CustomCombinedChartView
        cv.showAxisLabels(showEarnings: self.timeInterval != Constants.TimeIntervals.day)
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
    
    func chartViewDidEndPanning(_ chartView: ChartViewBase){
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
        self.timeButtonPressed(sender as! UIButton, chartData: company.getDailyData(22), timeInterval: Constants.TimeIntervals.one_month)
    }
    
    @IBAction func ThreeMonthsButtonPressed(_ sender: Any) {
        self.timeButtonPressed(sender as! UIButton, chartData: company.getDailyData(65), timeInterval: Constants.TimeIntervals.three_month)
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
        if chartData.count > 0 {
            setTopBarValues(startPrice: chartData[0].close!, endPrice: latestQuote.latestPrice!, selected: false)
        }
        
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
        let x = self.newsVC
        x.updateData()
        print("\(self.handlersDone) news done")
        self.incrementLoadingProgress()
    }
    
    private func handleAdvancedStats(advancedStats: AdvancedStats){
        self.company.advancedStats = advancedStats
        let x = self.keyStatsVC as! StatsVC
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
    
    func pagingViewController(_ pagingViewController: PagingViewController, viewControllerAt index: Int) -> UIViewController {
        return self.pageVCList[index]
    }
    
    func pagingViewController(_ pagingViewController: PagingViewController, pagingItemAt index: Int) -> PagingItem {
        return IconItem(icon: icons[index], index: index)
    }
    
    func numberOfViewControllers(in: PagingViewController) -> Int {
        return self.pageVCList.count
    }
}

extension StockDetailsVC: PagingViewControllerDelegate {
    func pagingViewController(_: PagingViewController, willScrollToItem pagingItem: PagingItem, startingViewController: UIViewController, destinationViewController: UIViewController) {
        //self.adjustContentHeight(vc: destinationViewController)
    }
    
    func pagingViewController(_ pagingViewController: PagingViewController, didScrollToItem pagingItem: PagingItem, startingViewController: UIViewController?, destinationViewController: UIViewController, transitionSuccessful: Bool) {
        if transitionSuccessful {
            self.adjustContentHeight(vc: destinationViewController)
        }
    }
}
