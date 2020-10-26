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
    @IBOutlet weak var totalDateAndVolumeView: UIView!
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
    @IBOutlet weak var slider52w: UISlider!
    @IBOutlet weak var sliderMin: UILabel!
    @IBOutlet weak var sliderMax: UILabel!
    
    @IBOutlet weak var smastack: UIStackView!
    @IBOutlet weak var sma20: UILabel!
    @IBOutlet weak var sma50: UILabel!
    @IBOutlet weak var sma100: UILabel!
    @IBOutlet weak var sma200: UILabel!
    @IBOutlet weak var toggleSmasButton: UIButton!
    @IBOutlet weak var toggleRsiButton: UIButton!
    
    public var showSmas:Bool = false
    public var showRsi:Bool = false
    
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
    private var scoresVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ScoresVC")
    private var financialsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FinVC")
    private var predictionsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PredictionsVC")
    private var premiumVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PremiumVC")
    
    private var stockUpdater:StockDataTask?
    private var pageVC: PagingViewController!
    
    private var dateOfLatestPriceData:String = ""
    
    fileprivate let icons = [
        "stats",
        "news",
        "wallet",
        "analysts",
        "scores",
        "star"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.delegate = self
        self.toggleRsiButton.layer.cornerRadius = 5
        self.toggleSmasButton.layer.cornerRadius = 5
        
        chartTypeButton.imageView!.contentMode = UIView.ContentMode.scaleAspectFit
        feedbackGenerator = UISelectionFeedbackGenerator()
        
        self.pageVCList = [
            self.keyStatsVC, self.newsVC, self.financialsVC, self.predictionsVC, self.scoresVC, self.premiumVC
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
        
        //setup general stock and price information
        stockDetailsNavView.logo.layer.cornerRadius = (stockDetailsNavView.logo.frame.width)/2
        stockDetailsNavView.logo.layer.masksToBounds = true
        
        let rangeImage:UIImage? = UIImage(systemName: "circle.fill")
        slider52w.setThumbImage(rangeImage, for: .normal)
        slider52w.tintColor = Constants.darkPink
        
        //setup chart buttons
        timeButtons = [button1D, button1M, button3M, button1Y, button5Y, buttonMax]
        button1D.backgroundColor = UIColor.white
        button1D.setTitleColor(Constants.darkGrey, for: .normal)
        timeInterval = Constants.TimeIntervals.day
        
        self.loadDynamicData()
    }
    
    
    //TODO reload outdated charts on view appear and during each scheduled task handler
    override func viewDidAppear(_ animated: Bool) {
        self.stockUpdater?.startTask()
        if self.dateOfLatestPriceData != "" && self.dateOfLatestPriceData != NumberFormatter.formatDateToYearMonthDayDashesString(Date()){
            self.refetchCurrentChart()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.stockUpdater?.stopTask()
    }
    
    public func loadDynamicData(){
        self.hideLoader(false)
                
        updateChartHeight()
        company = Dataholder.selectedCompany
        //let pageVC: StatsNewsPageViewController = self.children.first as! StatsNewsPageViewController
        //pageVC.pageDelegate = self
                
        self.stockUpdater?.hibernating = false
        self.stockUpdater = StockUpdater(caller: self, company: company, timeInterval: 5.0)
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
        //setup price info that will need to be updated each time quote is retreived
        if (latestQuote != nil){
            //setTopBarValues(startPrice: 0.0, endPrice: latestQuote.latestPrice!, selected: false)
        }
                
        //load charts
        setGlobalChartOptions()
        volumeChartFormatter = VolumeChartFormatter()
        self.chartView.setup(delegate: self)
        self.chartView.delegate = self
                
        //start information retrieval processes
        self.totalHandlers = 2
        if Constants.subscriber {
            self.totalHandlers += 1
            NetworkManager.getMyRestApi().getPremiumData(symbol: company.symbol, completionHandler: handlePremiumData)
        }
        NetworkManager.getMyRestApi().getAllFreeData(symbol: company.symbol, completionHandler: handleAllData)
        NetworkManager.getMyRestApi().getNonIntradayChart(symbol: company.symbol, timeframe: .daily, completionHandler: self.handleDailyChart)
                
        self.adjustContentHeight(vc: self.keyStatsVC)
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
            self.dateOfLatestPriceData = intradayChart[0].dateLabel!

            if quote.symbol == nil {
                return
            }
            print("updated " + String(quote.latestPrice!) + " " + String(intradayChart.count) + " values")
        } else if self.company.quote != nil {
            quote = self.company.quote!
        }
        
        if quote.isUSMarketOpen {
            self.stockUpdater?.hibernating = false
        } else {
            self.stockUpdater?.hibernating = true
        }
        
        self.isMarketOpen = quote.isUSMarketOpen
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
            self.set52wSlider(quote: quote, price: quote.latestPrice!)
            if let pvc = self.predictionsVC as? PredictionsViewController {
                if pvc.isViewLoaded {
                    pvc.updateData()
                }
            }
        }
    }
    
    private func set52wSlider(quote:Quote, price:Double){
        let numerator = price - quote.week52Low!
        let denominator = quote.week52High! - quote.week52Low!
        self.slider52w.value = Float(numerator / denominator)
        self.sliderMin.text = String(quote.week52Low!)
        self.sliderMax.text = String(quote.week52High!)
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
            Dataholder.watchlistManager.addCompany(company: self.company){
                self.addedToWatchlist(true)
                self.hideLoader(true)
            }
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
            priceDetailsView.priceChangeAndPercent.setPriceChange(price: latestQuote.change!, percent: latestQuote.changePercent!)
        } else {
            let priceChange = endPrice - startPrice
            let percentChange = (priceChange / startPrice)
            priceDetailsView.priceChangeAndPercent.setPriceChange(price: priceChange, percent: percentChange)
        }
        
        var datetext = "market closed - "
        datetime.textColor = UIColor.gray
        if self.isMarketOpen {
            datetext = "market open - "
            datetime.textColor = Constants.green
        }
        if latestQuote.latestTime!.contains(":"){
            datetext += "last updated \(latestQuote.latestTime!) ET"
        } else {
            datetext += "last updated \(latestQuote.latestTime!)"
        }
        datetime.text = datetext
    }
    
    //SAM-TODO remove average volume argument and encorporate low/high volume into analysis
    public func setVolumeValues(averageVolume:Double, totalVol:Double){
        self.totalVol.text = String("TODAY'S VOLUME: \(NumberFormatter.formatNumber(num: totalVol))")
    }
    
    private func handlePremiumData(kscores: Kscore, brainSentiment: BrainSentiment) {
        self.company.kscores = kscores
        self.company.brainSentiment = brainSentiment
        let premiumVC = self.premiumVC as! StatsVC
        premiumVC.updateData()
        self.incrementLoadingProgress()

    }
    
    private func handleAllData(generalInfo: GeneralInfo, peerQuotes:[Quote], keystats: KeyStats, news: [News], priceTarget: PriceTarget, earnings: [Earnings], recommendations: Recommendations, advancedStats: AdvancedStats, cashflow: [CashFlow], cashflowAnnual:[CashFlow], income: [Income], incomeAnnual: [Income], insiders: [Insider], scores:Scores, priceTargetTopAnalysts: PriceTargetTopAnalysts?){
        self.company.generalInfo = generalInfo
        self.company.fullName = self.company.generalInfo!.companyName!
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
        self.company.scores = scores
    
        DispatchQueue.main.async {
            self.stockDetailsNavView.ticker.text = self.company.symbol
            self.stockDetailsNavView.name.text = self.company.fullName
        }
        
        let keystatsVC = self.keyStatsVC as! StatsVC
        keystatsVC.updateData()
        let newsVC = self.newsVC
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
    
    private func handleDayChartNoProgress(_ chartData:[Candle]){
        self.handleDayChartMain(chartData, updateProgress: false)
    }
    
    private func handleDayChartData(_ chartData:[Candle]){
        self.handleDayChartMain(chartData, updateProgress: true)
    }
    
    private func handleDayChartMain(_ chartData:[Candle], updateProgress: Bool){
        company.setMinuteData(chartData, open: self.isMarketOpen)
        if self.timeInterval == Constants.TimeIntervals.day {
            self.chartView.setChartData(chartData: company.minuteData)
        }
        print("\(self.handlersDone) day chart done")
        if updateProgress {
            self.incrementLoadingProgress()
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
        
        if self.showSmas {
            if let sma20val = candle.sma20 {
                sma20.text = "MA20:\(String(format: "%.2f", sma20val))"
            } else {
                sma20.text = ""
            }
            if let sma50val = candle.sma50 {
                sma50.text = "MA50:\(String(format: "%.2f", sma50val))"
            } else {
                sma50.text = ""
            }
            if let sma100val = candle.sma100 {
                sma100.text = "MA100:\(String(format: "%.2f", sma100val))"
            } else {
                sma100.text = ""
            }
            if let sma200val = candle.sma200 {
                sma200.text = "MA200:\(String(format: "%.2f", sma200val))"
            } else {
                sma200.text = ""
            }
            smastack.isHidden = false
        } else {
            smastack.isHidden = true
        }
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
        set52wSlider(quote: self.latestQuote, price: candle.close!)
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
        smastack.isHidden = true
        totalDateAndVolumeView.isHidden = false
        chartView.highlightValue(nil)
        let chartData = self.chartView.getChartData(candleMode: self.candleMode)
        
        if self.timeInterval == Constants.TimeIntervals.day {
            setTopBarValues(startPrice: latestQuote.previousClose ?? chartData[0].close!, endPrice: latestQuote.latestPrice!, selected: false)
        } else {
            setTopBarValues(startPrice: chartData[0].close!, endPrice: latestQuote.latestPrice!, selected: false)
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
                        self.chartView.setChartData(chartData: self.company.getWeeklyData(52))
                    }
                }
            } else {
                self.optionTapped(.toggleShowCandleBar)
            }
        }
        self.hideShowRsiAndSmaButtons()
    }
    
    @IBAction func toggleSmasButtonTapped(_ sender: Any) {
        self.showSmas = !showSmas
        if showSmas {
            self.toggleSmasButton.backgroundColor = Constants.darkPink
            self.toggleSmasButton.tintColor = .white
        } else {
            self.toggleSmasButton.backgroundColor = Constants.veryLightGrey
            self.toggleSmasButton.tintColor = .darkGray
        }
        self.chartView.updateChart()
    }
    
    @IBAction func toggleRsiButtonTapped(_ sender: Any) {
        self.showRsi = !showRsi
        if showRsi {
            self.toggleRsiButton.backgroundColor = Constants.darkPink
            self.toggleRsiButton.tintColor = .white
        } else {
            self.toggleRsiButton.backgroundColor = Constants.veryLightGrey
            self.toggleRsiButton.tintColor = .darkGray
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
    
    @IBAction func TwentyYearButtonPressed(_ sender: Any) {
        self.hideLoader(false)
        NetworkManager.getMyRestApi().getNonIntradayChart(symbol: self.company.symbol, timeframe: MyRestAPI.ChartTimeFrames.monthly) { (candles) in
            self.company.monthlyData = candles
            DispatchQueue.main.async {
                self.hideLoader(true)
                self.timeButtonPressed(sender, chartData: self.company.getMonthlyData(240), timeInterval: Constants.TimeIntervals.twenty_year)
            }
        }
    }
    
    @IBAction func OneYearButtonPressed(_ sender: Any) {
        self.hideLoader(false)
        if self.candleMode {
            NetworkManager.getMyRestApi().getNonIntradayChart(symbol: self.company.symbol, timeframe: MyRestAPI.ChartTimeFrames.weekly) { (candles) in
                self.company.weeklyData = candles
                DispatchQueue.main.async {
                    self.hideLoader(true)
                    self.timeButtonPressed(sender, chartData: self.company.getWeeklyData(52), timeInterval: Constants.TimeIntervals.one_year)
                }
            }
        } else {
            NetworkManager.getMyRestApi().getNonIntradayChart(symbol: self.company.symbol, timeframe: MyRestAPI.ChartTimeFrames.daily) { (candles) in
                self.company.dailyData = candles
                DispatchQueue.main.async {
                    self.hideLoader(true)
                    self.timeButtonPressed(sender, chartData: self.company.getDailyData(265), timeInterval: Constants.TimeIntervals.one_year)
                }
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
        let timeIntervals:[Constants.TimeIntervals] = [.day, .one_month, .three_month, .one_year, .five_year, .twenty_year]
        let index = timeIntervals.firstIndex(of: timeInterval)

        self.timeInterval = timeInterval
        if chartData.count > 0 {
            if self.timeInterval == .day {
                setTopBarValues(startPrice: latestQuote.previousClose ?? chartData[0].close!, endPrice: latestQuote.latestPrice!, selected: false)
            } else {
                setTopBarValues(startPrice: chartData[0].close!, endPrice: latestQuote.latestPrice!, selected: false)
            }
        }

        self.hideShowRsiAndSmaButtons()
        
        for i in 0..<timeButtons.count {
            let button = timeButtons[i]
            if i == index {
                button.backgroundColor = UIColor.white
                button.setTitleColor(Constants.darkGrey, for: .normal)
            } else {
                button.backgroundColor = Constants.darkPink
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
        case .twenty_year:
            self.TwentyYearButtonPressed(self)
        case .max:
            return
        }
    }
    
    private func hideShowRsiAndSmaButtons(){
        if self.timeInterval != .day {
            self.toggleSmasButton.isHidden = false
            self.toggleRsiButton.isHidden = false
        } else {
            self.toggleSmasButton.isHidden = true
            self.toggleRsiButton.isHidden = true
        }
//        if self.timeInterval == .one_month || self.timeInterval == .three_month || (self.timeInterval == .one_year && !self.candleMode) {
//            self.toggleRsiButton.isHidden = false
//        } else {
//            self.toggleRsiButton.isHidden = true
//        }
    }
  
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
    
    public func isVisible(view: UIView) -> Bool {
        func isVisible(view: UIView, inView: UIView?) -> Bool {
            guard let inView = inView else { return true }
            let viewFrame = inView.convert(view.bounds, from: view)
            if viewFrame.intersects(CGRect(x: inView.bounds.minX, y: inView.bounds.minY - (viewFrame.height/2), width: inView.bounds.width, height: inView.bounds.height)) {
                return isVisible(view: view, inView: inView.superview)
            }
            return false
        }
        return isVisible(view: view, inView: view.superview)
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

