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
import SPStorkController
import FCAlertView

class StockDetailsVC: DemoBaseViewController, Updateable, ShadowButtonDelegate {

    @IBOutlet var mainView: UIView!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var creditBalanceButton: ShadowButtonView!
    @IBOutlet weak var stockDetailsNavView: StockDetailsNavView!
    @IBOutlet weak var priceDetailsView: StockDetailsSummaryView!
    @IBOutlet weak var chartView: CustomCombinedChartView!
    @IBOutlet weak var candlePricesWrapper: UIView!
    @IBOutlet weak var candlePricesView: CandlePricesView!
    @IBOutlet weak var candleMarkerView: MarkerView!
    @IBOutlet weak var chartTypeButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var totalDateAndVolumeView: UIView!
    @IBOutlet weak var datetime: UILabel!
    @IBOutlet weak var totalVol: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var innerScroll: UIView!
    @IBOutlet weak var chartTimeView: UIStackView!
    @IBOutlet weak var pagingView: UIView!
    @IBOutlet weak var pagingViewDummy: UIView!
    @IBOutlet weak var chartViewWrapperHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var timeViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pagingViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var loaderView: UIView!
    @IBOutlet weak var watchlistButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var toggleVwap: UIButton!
    public var showVwap:Bool = false
    public var candleMode = false

    public var company:Company!
    public var latestQuote:Quote!
    private var isMarketOpen:Bool = true
    private var priceChartFormatter:PriceChartFormatter!
    private var volumeChartFormatter:VolumeChartFormatter!
    
    private var feedbackGenerator: UISelectionFeedbackGenerator!
    public var timeInterval = Constants.TimeIntervals.day
    private var timeButtons:[UIButton]!
        
    private var handlersDone = 0
    private var totalHandlers = 0
    
    private var pageVCList:[UIViewController] = []
    private var pageVCDummyList:[UIViewController] = []
    private var keyStatsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StatsVC")
    private var newsVC2 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StockNewsVC") as! NewsViewController
    private var scoresVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ScoresVC")
    private var financialsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FinVC")
    private var predictionsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PredictionsVC")
    private var premiumVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PremiumVC") as! PremiumViewController
    
    private var stockUpdater:StockDataTask?
    private var pageVC: PagingViewController! = PagingViewController()
    private var pageVCDummy: PagingViewController! = PagingViewController()
    private var dummyShowing:Bool = false
    private var dateOfLatestPriceData:String = ""
    private var lastContentOffset: CGFloat = 0
    
    fileprivate let icons = [
        "bars",
        "news",
        "dollarsign",
        "analysts",
        "scores",
        "premium-icon"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pagingViewDummy.isHidden = true
        mainView.addPurpleGradientBackground()
        self.scrollView.delegate = self
        Dataholder.subscribeForCreditBalanceUpdates(self)
        self.creditBalanceButton.credits.text = String("\(Dataholder.getCreditBalance())")
        self.creditBalanceButton.delegate = self
        self.creditBalanceButton.bgColor = .clear
//        self.creditBalanceButton.shadColor = UIColor.clear.cgColor
//        self.creditBalanceButton.shadColor = UIColor(red: 100.0/255.0, green: 60.0/255.0, blue: 25.0/255.0, alpha: 1.0).cgColor

        self.scrollView.delegate = self
        self.toggleVwap.layer.cornerRadius = 5
        
        self.premiumVC.stockDetailsDelegate = self
        chartTypeButton.imageView!.contentMode = UIView.ContentMode.scaleAspectFit
        feedbackGenerator = UISelectionFeedbackGenerator()
        
        self.pageVCList = [
            self.keyStatsVC, self.newsVC2, self.financialsVC, self.predictionsVC, self.scoresVC, self.premiumVC
        ]
        self.pageVCDummyList = [
            UIViewController(), UIViewController(), UIViewController(), UIViewController(), UIViewController(), UIViewController()
        ]
        self.initPageVc(self.pagingViewDummy, pageVC: self.pageVCDummy, identifier: "pageVCDummy")
        self.initPageVc(self.pagingView, pageVC: self.pageVC, identifier: "pageVC")
        //setup general stock and price information
        
        //setup chart buttons
        timeButtons = [button1D, button1M, button3M, button1Y, button5Y]
        for butt in timeButtons {
            butt.layer.cornerRadius = butt.layer.frame.height / 2
        }
        button1D.backgroundColor = UIColor.white
        button1D.setTitleColor(Constants.darkGrey, for: .normal)
        timeInterval = Constants.TimeIntervals.day
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleDummyTap(_:)))
//        self.pagingViewDummy.addGestureRecognizer(tap)
        
        self.loadDynamicData()
    }
    
    @objc func handleDummyTap(_ sender: UITapGestureRecognizer? = nil) {
        print("tapped the fucking dummy")
    }
    
    private func initPageVc(_ pagingView:UIView, pageVC: PagingViewController, identifier: String){
        pageVC.restorationIdentifier = identifier
        pageVC.register(IconPagingCell.self, for: IconItem.self)
        pageVC.menuHorizontalAlignment = .center
        pageVC.menuInsets = UIEdgeInsets(top: -5.0, left: 10.0, bottom: -5.0, right: 10.0)
        pageVC.menuItemSize = .sizeToFit(minWidth: 60, height: 60)
        pageVC.menuBackgroundColor = Constants.themeDarkBlue
        pageVC.indicatorColor = .clear
        pageVC.borderColor = .clear
        pageVC.dataSource = self
        pageVC.delegate = self
        pageVC.select(pagingItem: IconItem(icon: icons[0], index: 0))
        self.addChild(pageVC)
        pagingView.addSubview(pageVC.view)
        self.mainView.bringSubviewToFront(pagingView)
        pageVC.didMove(toParent: self)
        pageVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageVC.view.leadingAnchor.constraint(equalTo: pagingView.leadingAnchor),
            pageVC.view.trailingAnchor.constraint(equalTo: pagingView.trailingAnchor),
            //pageVC.view.bottomAnchor.constraint(equalTo: pagingView.bottomAnchor),
            pagingView.bottomAnchor.constraint(equalTo: pageVC.view.bottomAnchor),
            pageVC.view.topAnchor.constraint(equalTo: pagingView.topAnchor)
        ])
        pageVC.selectedFont = UIFont(name: "HelveticaNeue-Thin", size: 12.0)!
        pageVC.backgroundColor = .clear
    }
    
    
    //TODO reload outdated charts on view appear and during each scheduled task handler
    override func viewDidAppear(_ animated: Bool) {
        self.stockUpdater?.startTask()
        if self.dateOfLatestPriceData != "" && self.dateOfLatestPriceData != NumberFormatter.formatDateToYearMonthDayDashesString(Date()){
            self.refetchCurrentChart()
        }
        
        AppReviewRequest.requestReviewIfNeeded()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.stockUpdater?.stopTask()
    }
    
    public func loadDynamicData(){
        self.hideLoader(false)
                
        updateChartHeight()
        company = Dataholder.selectedCompany
                
        self.stockUpdater?.hibernating = false
        self.stockUpdater = StockUpdater(caller: self, company: company, timeInterval: 60.0)
        self.stockUpdater?.startTask()
                
        //watchlist button
        if Dataholder.watchlistManager.getWatchlist().contains(company){
            self.addedToWatchlist(true)
        } else {
            self.addedToWatchlist(false)
        }
                
        stockDetailsNavView.ticker.text = company.symbol
        stockDetailsNavView.name.text = company.fullName
                
        latestQuote = company.quote
                
        //load charts
        setGlobalChartOptions()
        volumeChartFormatter = VolumeChartFormatter()
        self.chartView.setup(delegate: self)
        self.chartView.delegate = self
        
        //start information retrieval processes
        self.totalHandlers = 2
        NetworkManager.getMyRestApi().getFirstTabData(symbol: company.symbol, completionHandler: handleKeyStats)
        NetworkManager.getMyRestApi().getNonIntradayChart(symbol: company.symbol, timeframe: .daily, completionHandler: self.handleDailyChart)
                
        self.adjustContentHeight(vc: self.keyStatsVC)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let h1 = self.candlePricesWrapper.bounds.height
        let h2 = self.chartView.bounds.height
        let h3 = self.chartTimeView.bounds.height
        let h4 = 25.0
        let totalHeight = h1 + h2 + h3 + h4
        if (self.lastContentOffset > scrollView.contentOffset.y) {
            if scrollView.contentOffset.y <= totalHeight && self.dummyShowing{
                print("hiding dummy")
                self.pagingViewDummy.isHidden = true
                self.dummyShowing = false
            }
        }
        else if (self.lastContentOffset < scrollView.contentOffset.y) {
            if scrollView.contentOffset.y >= totalHeight && !self.dummyShowing{
                print("showing dummy")
                self.pagingViewDummy.isHidden = false
                self.dummyShowing = true
            }
        }

        // update the new position acquired
        self.lastContentOffset = scrollView.contentOffset.y
    }
    
    func updateFromScheduledTask(_ data:Any?) {
        var quote:Quote = Quote()
        if let quoteAndIntradayChart = data as? QuoteAndIntradayChart {
            quote = quoteAndIntradayChart.quote
            let intradayChart = quoteAndIntradayChart.intradayChart
            
            self.handleDayChartNoProgress(intradayChart)
            
            if self.dateOfLatestPriceData != "" && intradayChart.count > 0 &&
                self.dateOfLatestPriceData != intradayChart[0].dateLabel {
                self.company.dailyData = []
                self.company.weeklyData = []
                self.company.monthlyData = []
            }
            if intradayChart.count > 0 {
                self.dateOfLatestPriceData = intradayChart[0].dateLabel!
            }

            if quote.symbol == nil {
                return
            }
            self.company.quote = quote
            if let latestPrice = self.company.quote?.latestPrice, self.company.estimatedEps != nil && self.company.estimatedEps != 0 {
                let peFwd = latestPrice / self.company.estimatedEps!
                self.company.peFwd = peFwd
            }
            let keystatsVC = self.keyStatsVC as! KeyStatsViewController
            keystatsVC.updateQuoteData()
            print("updated " + String(quote.latestPrice!) + " " + String(intradayChart.count) + " values")
        } else if self.company.quote != nil {
            quote = self.company.quote!
        }
        
        if Dataholder.isUSMarketOpen {
            self.stockUpdater?.hibernating = false
        } else {
//            self.stockUpdater?.hibernating = true
        }
        
        self.isMarketOpen = Dataholder.isUSMarketOpen
        self.latestQuote = quote
        if latestQuote == nil || latestQuote.symbol == nil {
            return
        }
        
        DispatchQueue.main.async {
            let chartData = self.chartView.getChartData(candleMode: self.candleMode)
            self.setVolumeValues(averageVolume: Double(quote.avgTotalVolume ?? 0), totalVol: Double(quote.latestVolume ?? 0))
            if chartData.count > 0 {
                if self.timeInterval == Constants.TimeIntervals.day {
                    self.setTopBarValues(startPrice: self.latestQuote.previousClose ?? chartData[0].close!, endPrice: self.latestQuote.latestPrice!, selected: false)
                } else {
                    self.setTopBarValues(startPrice: chartData[0].close!, endPrice: self.latestQuote.latestPrice!, selected: false)
                }
            }
            if let pvc = self.predictionsVC as? PredictionsViewController {
                if pvc.isViewLoaded {
                    pvc.updateData()
                }
            }
        }
    }
    
    private func incrementLoadingProgress(){
        self.handlersDone+=1
        let total = self.totalHandlers
        if (self.handlersDone >= total){
            self.adjustContentHeight(vc: self.keyStatsVC)
            self.hideLoader(true)
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
            Dataholder.watchlistManager.addCompany(company: self.company){ added in
                if added {
                    self.addedToWatchlist(true)
                } else {
                    AlertDisplay.showAlert("Error", message: "Watchlist limit reached")
                }
                self.hideLoader(true)
            }
        }
    }
    
    public func addedToWatchlist(_ added:Bool) {
        DispatchQueue.main.async {
            if added {
                self.watchlistButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
                self.watchlistButton.tintColor = Constants.lightPurple
            } else {
                self.watchlistButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
                self.watchlistButton.tintColor = .white
            }
        }
    }
    
    public func hideLoader(_ hide:Bool){
        DispatchQueue.main.async {
            if hide {
                self.activityIndicator.stopAnimating()
            } else {
                self.activityIndicator.startAnimating()
            }
            self.loaderView.isHidden = hide
        }
    }
    
    //when receving new quote, call this to update top bar values
    private func setTopBarValues(startPrice: Double, endPrice: Double, selected: Bool){
        priceDetailsView.priceLabel.text = String(format: "%.2f", endPrice)
        
        if timeInterval == Constants.TimeIntervals.day && !selected {
            priceDetailsView.priceChangeAndPercent.setPriceChange(price: latestQuote.change!, percent: latestQuote.changePercent! / 100.0)
        } else {
            let priceChange = endPrice - startPrice
            let percentChange = (priceChange / startPrice)
            priceDetailsView.priceChangeAndPercent.setPriceChange(price: priceChange, percent: percentChange)
        }
        
        var datetext = "market closed"
        datetime.textColor = UIColor.gray
        if self.isMarketOpen {
            datetext = "market open"
            datetime.textColor = Constants.lightGrey
        }
//        if latestQuote != nil && latestQuote.latestUpdate != nil {
//            datetext += " \(latestQuote.latestUpdate!)"
//        }
        datetime.text = datetext
    }
    
    //TODO-SAM: remove average volume argument and encorporate low/high volume into analysis
    public func setVolumeValues(averageVolume:Double, totalVol:Double){
        self.totalVol.text = String("\(NumberFormatter.formatNumber(num: totalVol))")
    }
    
    private func handleKeyStats(generalInfo: GeneralInfo, peerQuotes:[Quote], insiders: Insider, estimatedEps: Double, advancedStats:AdvancedStats) {
        self.company.generalInfo = generalInfo
        self.company.fullName = self.company.generalInfo!.companyName ?? ""
        self.company.peerQuotes = peerQuotes.filter({ (q) -> Bool in
            q.symbol != nil && q.symbol != ""
        })
        self.company.insiders = insiders
        self.company.advancedStats = advancedStats
        self.company.estimatedEps = estimatedEps
        if let latestPrice = self.company.quote?.latestPrice, self.company.estimatedEps != nil && self.company.estimatedEps != 0 {
            let peFwd = latestPrice / estimatedEps
            self.company.peFwd = peFwd
        }
        
        DispatchQueue.main.async {
            self.stockDetailsNavView.ticker.text = self.company.symbol
            self.stockDetailsNavView.name.text = self.company.fullName
        }
        
        let keystatsVC = self.keyStatsVC as! StatsVC
        keystatsVC.updateData()
        
        self.incrementLoadingProgress()
    }
    
    private func handleAllData(generalInfo: GeneralInfo, peerQuotes:[Quote], keystats: KeyStats, news: [News], priceTarget: PriceTarget, earnings: [Earnings], recommendations: Recommendations, advancedStats: AdvancedStats, cashflow: [CashFlow], cashflowAnnual:[CashFlow], income: [Income], incomeAnnual: [Income], insiders: Insider, priceTargetTopAnalysts: PriceTargetTopAnalysts?, allTipranksAnalystsForStock:[ExpertAndRatingForStock], priceTargetsOverTime:[SimpleTimeAndPrice], bestPriceTargetsOverTime:[SimpleTimeAndPrice]){
        self.company.generalInfo = generalInfo
        self.company.fullName = self.company.generalInfo!.companyName ?? ""
        self.company.peerQuotes = peerQuotes.filter({ (q) -> Bool in
            q.symbol != nil && q.symbol != ""
        })
        self.company.keyStats = keystats
        self.company.news = news
        self.company.priceTarget = priceTarget
        self.company.cashflow = cashflow
        self.company.cashflowAnnual = cashflowAnnual
        self.company.income = income
        self.company.incomeAnnual = incomeAnnual
        self.company.recommendations = recommendations
        self.company.earnings = earnings
        self.company.advancedStats = advancedStats
        self.company.insiders = insiders
        self.company.priceTargetTopAnalysts = priceTargetTopAnalysts
        self.company.tipranksAllAnalysts = allTipranksAnalystsForStock
        self.company.priceTargetsOverTime = priceTargetsOverTime
        self.company.bestPriceTargetsOverTime = bestPriceTargetsOverTime
    
        DispatchQueue.main.async {
            self.stockDetailsNavView.ticker.text = self.company.symbol
            self.stockDetailsNavView.name.text = self.company.fullName
        }
        
        let keystatsVC = self.keyStatsVC as! StatsVC
        keystatsVC.updateData()
        let newsVC = self.newsVC2
        newsVC.updateData()
        let financialsVC = self.financialsVC as! StatsVC
        financialsVC.updateData()
        let predictionsVC = self.predictionsVC as! StatsVC
        predictionsVC.updateData()
        
        self.incrementLoadingProgress()
    }
    
    public func adjustContentHeight(vc: UIViewController){
        DispatchQueue.main.async{
            let currentVC = vc as! StatsVC
            self.pagingViewHeightConstraint.constant = currentVC.getContentHeight() + 80
        }
    }
    
    public func updateData(vc: UIViewController){
        DispatchQueue.main.async{
            let currentVC = vc as! StatsVC
            currentVC.updateData()
        }
    }
    
    private func handleDayChartNoProgress(_ chartData:[Candle]){
        self.handleDayChartMain(chartData, updateProgress: false)
    }
    
    private func handleDayChartData(_ chartData:[Candle]){
        self.handleDayChartMain(chartData, updateProgress: true)
    }
    
    private func handleDayChartMain(_ chartData:[Candle], updateProgress: Bool){
        DispatchQueue.main.async {
            self.company.setMinuteData(chartData, open: self.isMarketOpen)
            if self.timeInterval == Constants.TimeIntervals.day {
                self.chartView.setChartData(chartData: self.company.minuteData)
            }
            print("\(self.handlersDone) day chart done")
            if updateProgress {
                self.incrementLoadingProgress()
            }
        }
    }
    
    private func handleDailyChart(_ candles:[Candle]){
        self.company.dailyData = candles
        self.incrementLoadingProgress()
    }
    
    private func handleWeeklyChart(_ candles:[Candle]){
         self.company.weeklyData = candles
         self.incrementLoadingProgress()
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
//        let cv = chartView as! CustomCombinedChartView
//        cv.hideAxisLabels(hideEarnings: self.timeInterval != Constants.TimeIntervals.day)
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
        
        totalDateAndVolumeView.isHidden = true
        
        // Adding top marker
        candleMarkerView.dateLabel.text = "\(candle.datetime!)"
        var x = highlight.xPx.rounded()
        if x+(candleMarkerView.bounds.width/2) > chartView.bounds.width {
            x = chartView.bounds.width - (candleMarkerView.bounds.width/2)
        }
        if x-(candleMarkerView.bounds.width/2) < 0 {
            x = (candleMarkerView.bounds.width/2)
        }
        candleMarkerView.center = CGPoint(x: x, y:0.0)
        candleMarkerView.isHidden = false
        
        if self.timeInterval == Constants.TimeIntervals.day {
            setTopBarValues(startPrice: latestQuote.previousClose ?? chartData[0].close!, endPrice: candle.close!, selected: true)
        } else {
            setTopBarValues(startPrice: chartData[0].close!, endPrice: candle.close!, selected: true)
        }
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
        totalDateAndVolumeView.isHidden = false
        chartView.highlightValue(nil)
        let chartData = self.chartView.getChartData(candleMode: self.candleMode)
        
        if chartData.count > 0 {
            if self.timeInterval == Constants.TimeIntervals.day {
                setTopBarValues(startPrice: latestQuote.previousClose ?? chartData[0].close!, endPrice: latestQuote.latestPrice!, selected: false)
            } else {
                setTopBarValues(startPrice: chartData[0].close!, endPrice: latestQuote.latestPrice!, selected: false)
            }
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func chartModeButtonPressed(_ sender: Any) {
        candleMode = !candleMode
        if !candleMode {
            chartTypeButton.setImage(UIImage(named: "candlebar_white.png"), for: .normal)
            if self.timeInterval == Constants.TimeIntervals.one_year {
                NetworkManager.getMyRestApi().getNonIntradayChart(symbol: self.company.symbol, timeframe: MyRestAPI.ChartTimeFrames.daily) { (candles) in
                    self.company.dailyData = candles
                    DispatchQueue.main.async {
                        self.hideLoader(true)
                        self.chartView.setChartData(chartData: self.company.getDailyData(260))
                    }
                }
            } else {
                self.optionTapped(.toggleShowCandleBar)
            }
        } else {
            chartTypeButton.setImage(UIImage(named: "linechart_white.png"), for: .normal)
            if self.timeInterval == Constants.TimeIntervals.one_year {
                NetworkManager.getMyRestApi().getNonIntradayChart(symbol: self.company.symbol, timeframe: MyRestAPI.ChartTimeFrames.weekly) { (candles) in
                    self.company.weeklyData = candles
                    DispatchQueue.main.async {
                        self.hideLoader(true)
                        self.chartView.setChartData(chartData: self.company.getDailyData(260))
                    }
                }
            } else {
                self.optionTapped(.toggleShowCandleBar)
            }
        }
//        self.hideShowVwapButtons()
    }
    
    @IBAction func toggleVwapButtonTapped(_ sender: Any) {
        self.showVwap = !showVwap
        if showVwap {
            self.toggleVwap.backgroundColor = Constants.darkPink
            self.toggleVwap.tintColor = .white
        } else {
            self.toggleVwap.backgroundColor = Constants.veryLightGrey
            self.toggleVwap.tintColor = .darkGray
        }
        self.chartView.updateChart()
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
    
    @IBOutlet weak var button1D: UIButton!
    @IBOutlet weak var button1M: UIButton!
    @IBOutlet weak var button3M: UIButton!
    @IBOutlet weak var button1Y: UIButton!
    @IBOutlet weak var button5Y: UIButton!
    
    @IBAction func OneDayButtonPressed(_ sender: Any) {
        self.timeButtonPressed(sender, chartData: company.minuteData, timeInterval: Constants.TimeIntervals.day)
    }
    
    @IBAction func OneMonthButtonPressed(_ sender: Any) {
        self.hideLoader(false)
        NetworkManager.getMyRestApi().getNonIntradayChart(symbol: self.company.symbol, timeframe: MyRestAPI.ChartTimeFrames.daily) { (candles) in
            self.company.dailyData = candles
            DispatchQueue.main.async {
                self.hideLoader(true)
                self.timeButtonPressed(sender, chartData: self.company.getDailyData(22), timeInterval: Constants.TimeIntervals.one_month)
            }
        }
    }
    
    @IBAction func ThreeMonthsButtonPressed(_ sender: Any) {
        self.hideLoader(false)
        NetworkManager.getMyRestApi().getNonIntradayChart(symbol: self.company.symbol, timeframe: MyRestAPI.ChartTimeFrames.daily) { (candles) in
            self.company.dailyData = candles
            DispatchQueue.main.async {
                self.hideLoader(true)
                self.timeButtonPressed(sender, chartData: self.company.getDailyData(65), timeInterval: Constants.TimeIntervals.three_month)
            }
        }
    }

    @IBAction func OneYearButtonPressed(_ sender: Any) {
        self.hideLoader(false)
            NetworkManager.getMyRestApi().getNonIntradayChart(symbol: self.company.symbol, timeframe: MyRestAPI.ChartTimeFrames.daily) { (candles) in
                self.company.dailyData = candles
                DispatchQueue.main.async {
                    self.hideLoader(true)
                    self.timeButtonPressed(sender, chartData: self.company.getDailyData(265), timeInterval: Constants.TimeIntervals.one_year)
                }
            }
    }
    
    @IBAction func FiveYearButtonPressed(_ sender: Any) {
        self.hideLoader(false)
        NetworkManager.getMyRestApi().getNonIntradayChart(symbol: self.company.symbol, timeframe: MyRestAPI.ChartTimeFrames.monthly) { (candles) in
            self.company.monthlyData = candles
            DispatchQueue.main.async {
                self.hideLoader(true)
                self.timeButtonPressed(sender, chartData: self.company.getMonthlyData(60), timeInterval: Constants.TimeIntervals.five_year)
            }
        }
    }
    
    private func timeButtonPressed(_ button: Any, chartData: [Candle], timeInterval: Constants.TimeIntervals){
        if !(button is UIButton) {
            return
        }
        let timeIntervals:[Constants.TimeIntervals] = [.day, .one_month, .three_month, .one_year, .five_year]
        let index = timeIntervals.firstIndex(of: timeInterval)

        self.timeInterval = timeInterval
        if chartData.count > 0 {
            if self.timeInterval == .day {
                setTopBarValues(startPrice: latestQuote.previousClose ?? chartData[0].close!, endPrice: latestQuote.latestPrice!, selected: false)
            } else {
                setTopBarValues(startPrice: chartData[0].close!, endPrice: latestQuote.latestPrice!, selected: false)
            }
        }

//        self.hideShowVwapButtons()
        
        for i in 0..<timeButtons.count {
            let button = timeButtons[i]
            if i == index {
                button.backgroundColor = UIColor.white
                button.setTitleColor(.darkGray, for: .normal)
            } else {
                button.backgroundColor = .clear
                button.setTitleColor(UIColor.white, for: .normal)
            }
        }
        self.chartView.setChartData(chartData: chartData)
        self.chartValueNothingSelected(self.chartView)
    }
    
    private func refetchCurrentChart(){
        switch self.timeInterval {
        case .day:
            return
        case .one_month:
            self.OneMonthButtonPressed(self)
        case .three_month:
            self.ThreeMonthsButtonPressed(self)
        case .six_month:
            return
        case .one_year:
            self.OneYearButtonPressed(self)
        case .five_year:
            self.FiveYearButtonPressed(self)
        }
    }
    
    private func hideShowVwapButtons(){
        if self.timeInterval != .day {
            self.toggleVwap.isHidden = false
        } else {
            self.toggleVwap.isHidden = true
        }
    }
    
    public func shadowButtonTapped(_ premiumPackage: PremiumPackage?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let purchaseVC = storyboard.instantiateViewController(withIdentifier: "purchaseCreditsVC") as! PurchaseViewController
        self.present(purchaseVC, animated: true, completion: nil)
    }
    
    public func creditBalanceUpdated() {
        DispatchQueue.main.async {
            self.creditBalanceButton.credits.text = String("\(Dataholder.getCreditBalance())")
        }
    }
    
    // MARK: - Navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//    }
    
//        if self.timeInterval == .one_month || self.timeInterval == .three_month || (self.timeInterval == .one_year && !self.candleMode) {
//            self.toggleRsiButton.isHidden = false
//        } else {
//            self.toggleRsiButton.isHidden = true
//        }
//    }
  
    //can use this function to trigger chart animations when views enter the visible frame
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if let x = predictionsVC as? PredictionsViewController {
//            if x.ratingsChartView != nil && !x.ratingsChartView.animated && self.isVisible(view: x.ratingsChartView) {
//                print("animation ratings chart")
//                x.ratingsChartView.animate()
//            }
//            if x.priceTargetChartView != nil && !x.priceTargetChartView.animated && self.isVisible(view: x.priceTargetChartView) {
//                print("animation price target chart")
//                x.priceTargetChartView.animate()
//            }
//        }
//    }
    
//    public func isVisible(view: UIView) -> Bool {
//        func isVisible(view: UIView, inView: UIView?) -> Bool {
//            guard let inView = inView else { return true }
//            let viewFrame = inView.convert(view.bounds, from: view)
//            if viewFrame.intersects(CGRect(x: inView.bounds.minX, y: inView.bounds.minY - (viewFrame.height/2), width: inView.bounds.width, height: inView.bounds.height)) {
//                return isVisible(view: view, inView: inView.superview)
//            }
//            return false
//        }
//        return isVisible(view: view, inView: view.superview)
//    }
    
    
    
}

extension StockDetailsVC: PagingViewControllerDataSource {
    
    func pagingViewController(_ pagingViewController: PagingViewController, viewControllerAt index: Int) -> UIViewController {
        if pagingViewController.restorationIdentifier == "pageVC" {
            return self.pageVCList[index]
        } else {
            return self.pageVCDummyList[index]
        }
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
//        self.pageVCDummy.select(pagingItem: pagingItem, animated: true)
    }
    
    func pagingViewController(_ pagingViewController: PagingViewController, didScrollToItem pagingItem: PagingItem, startingViewController: UIViewController?, destinationViewController: UIViewController, transitionSuccessful: Bool) {
        self.pageVCDummy.select(pagingItem: pagingItem, animated: true)
        if transitionSuccessful && pagingViewController.restorationIdentifier == "pageVC" {
            self.adjustContentHeight(vc: destinationViewController)
            self.updateData(vc: destinationViewController)
        }
    }
    
    func pagingViewController(_ pagingViewController: PagingViewController, didSelectItem pagingItem: PagingItem) {
        let i = pagingItem as! IconItem
        if pagingViewController.restorationIdentifier == "pageVC" {
            self.pageVCDummy.select(pagingItem: pagingItem, animated: true)
        } else {
            self.pageVC.select(pagingItem: pagingItem, animated: true)
        }
    }
}

