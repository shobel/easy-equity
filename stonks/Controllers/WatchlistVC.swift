//
//  WatchlistTVC.swift
//  stonks
//
//  Created by Samuel Hobel on 9/28/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import UIKit
import AuthenticationServices
import SPStorkController
import SwiftyJSON
import ObjectMapper

class WatchlistVC: UIViewController, Updateable {
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerBgView: UIView!
    @IBOutlet weak var watchlistContainer: UIView!
    @IBOutlet weak var portfolioContainer: UIView!
    @IBOutlet weak var portfolioHeaderChange: UIStackView!
    @IBOutlet weak var portfolioHeaderGain: UIStackView!
    @IBOutlet weak var portfolioTableChange: UITableView!
    @IBOutlet weak var portfolioTableGain: UITableView!
    
    @IBOutlet weak var noPortfolioView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var watchlistUpdater: WatchlistUpdater?
    private var watchlistManager:WatchlistManager!
    private var firstUpdateDone:Bool = false
    
    @IBOutlet weak var selectedScoreSystemLabel: UILabel!
    private var selectedScoringSystem:String = ""
    private var scoreDict:[String:(String, Double)] = [:]
    
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var emptyImage: UIImageView!
    
    private var lastRefresh:Double = 0
    private var holdings:[Holding] = []
    private var account:BrokerageAccount?
    private var watchlist:[Company] = []
    private var portfolioCompanies:[Company] = []
    private var currentSort:String = "CHANGE"
    private var sortAsc:Bool = false
    private var currentGainSort:String = "DAY" //"GAIN"
    private var gainSortAsc:Bool = false
    private var watchlistMode:Bool = true
    private var gainMode:Bool = true
    @IBOutlet weak var dayPL: UILabel!
    
    private var portfolioQuoteLookup:[String:Quote] = [:]
    private var totalPortValue:Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.activityIndicator.startAnimating()
        self.activityIndicator.isHidden = true
        
        self.portfolioContainer.isHidden = true
        
//        Dataholder.subscribeForCreditBalanceUpdates(self)
        //self.creditBalanceView.delegate = self
        //self.creditBalanceView.bgColor = .clear
        //self.creditBalanceView.shadColor = UIColor(red: 100.0/255.0, green: 60.0/255.0, blue: 25.0/255.0, alpha: 1.0).cgColor
        //self.headerBgView.addPinkGradientBackground()
        
        self.watchlistManager = Dataholder.watchlistManager
        self.watchlistManager.watchlistVC = self
        self.watchlist = watchlistManager.getWatchlist()
        
//        self.headerBgView.layer.shadowColor = UIColor.white.cgColor
//        self.headerBgView.layer.shadowOpacity = 0.7
//        self.headerBgView.layer.shadowOffset = .zero
//        self.headerBgView.layer.shadowRadius = 3
        
        self.mainView.addPurpleGradientBackground()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorInset = UIEdgeInsets.zero
        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl!.addTarget(self, action: #selector(handleRefresh), for: UIControl.Event.valueChanged)
        
        self.portfolioTableChange.delegate = self
        self.portfolioTableChange.dataSource = self
        self.portfolioTableGain.delegate = self
        self.portfolioTableGain.dataSource = self
        
        self.portfolioTableGain.backgroundColor = .clear
        self.portfolioTableChange.backgroundColor = .clear
        
//        self.tableView.backgroundView = nil
//        self.tableView.backgroundColor = UIColor.white
        
        self.emptyImage.image = UIImage(named: "abducted.png")!.alpha(0.7)
        NetworkManager.getMyRestApi().getCreditsForCurrentUser { credits in
            Dataholder.updateCreditBalance(credits)
        }
        self.loadWatchlist()
        self.loadPortfolio()
    }
    
    /* helps the rating score colors stick better when moving from other views to this one */
    override func viewWillAppear(_ animated: Bool) {
//        self.watchlistUpdated()
//        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //load watchlist if watchlist is empty or scoring system has changed
        //dont have to worry about watchlist changing here, there is a handler for that down below
        let newScoringSystem = Dataholder.currentScoringSystem
        if !newScoringSystem.isEmpty && self.selectedScoringSystem != newScoringSystem {
            self.selectedScoringSystem = Dataholder.currentScoringSystem
            self.refreshData()
        } else if self.selectedScoringSystem == "USER_CUSTOMIZED" && self.lastRefresh < Dataholder.lastScoreConfigChange {
            self.refreshData()
        }
        //self.creditBalanceView.credits.text = String("\(Dataholder.getCreditBalance())")
        
        self.account = Dataholder.account
        self.holdings = Dataholder.holdings.filter({ h in
            h.symbol != nil && !h.symbol!.isEmpty && h.symbol!.count <= 5
        })
        if holdings == nil || holdings.count == 0 {
            self.portfolioCompanies = []
            self.watchlistManager.setPortfolio(self.portfolioCompanies)
        }
        if holdings.count > portfolioCompanies.count {
            self.loadPortfolio()
        }
        if self.account == nil {
            self.noPortfolioView.isHidden = false
        } else {
            self.noPortfolioView.isHidden = true
        }
        self.gainSort()
        self.tableView.reloadData()
        self.portfolioTableChange.reloadData()
        self.portfolioTableGain.reloadData()
    
    }
    
    @IBAction func modeChanged(_ sender: Any) {
        self.watchlistMode = !self.watchlistMode
        self.hideShowTables()
    }
    @IBAction func gainModeChange(_ sender: Any) {
        self.gainMode = !self.gainMode
        self.hideShowTables()
    }
    
    private func hideShowTables(){
        if self.watchlistMode {
            self.watchlistContainer.isHidden = false
            self.portfolioContainer.isHidden = true
        } else {
            self.watchlistContainer.isHidden = true
            self.portfolioContainer.isHidden = false
            if self.gainMode {
                self.portfolioHeaderGain.isHidden = false
                self.portfolioHeaderChange.isHidden = true
                self.portfolioTableGain.isHidden = false
                self.portfolioTableChange.isHidden = true
            } else {
                self.portfolioHeaderGain.isHidden = true
                self.portfolioHeaderChange.isHidden = false
                self.portfolioTableGain.isHidden = true
                self.portfolioTableChange.isHidden = false
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //do we stop the watchlist updater while not on the watchlist? or just always have it going for simplicity?
    }
    
    private func loadPortfolio(){
        if Dataholder.account == nil {
            NetworkManager.getMyRestApi().getLinkedAccountAndHoldings { account, holdings in
                if account != nil {
                    self.account = account
                    self.holdings = holdings.filter({ h in
                        h.symbol != nil && !h.symbol!.isEmpty && h.symbol!.count <= 5
                    })
                    var portfolioCompanies:[Company] = []
                    for i in 0..<holdings.count {
                        let h = holdings[i]
                        let c = Company(symbol: h.symbol ?? "", fullName: h.name ?? "")
//                        self.totalPortValue += (h.close_price ?? 0.0) * (h.quantity ?? 0.0)
                        portfolioCompanies.append(c)
                    }
                    self.totalPortValue = (self.account?.balance?.current ?? 0.0) + (self.account?.balance?.available ?? 0.0)
                    self.portfolioCompanies = portfolioCompanies
                    Dataholder.account = account
                    Dataholder.holdings = holdings
                    self.watchlistManager.setPortfolio(self.portfolioCompanies)
                    if self.watchlistUpdater != nil {
                        self.watchlistUpdater?.timer?.fire()
                    }
                    DispatchQueue.main.async {
                        self.portfolioTableGain.reloadData()
                        self.portfolioTableChange.reloadData()
                        self.noPortfolioView.isHidden = true
                    }
                } else {
                    DispatchQueue.main.async {
                        self.noPortfolioView.isHidden = false
                    }
                }
            }
        } else {
            var portfolioCompanies:[Company] = []
            for i in 0..<holdings.count {
                let h = holdings[i]
                let c = Company(symbol: h.symbol ?? "", fullName: h.name ?? "")
                self.totalPortValue += (h.close_price ?? 0.0) * (h.quantity ?? 0.0)
                portfolioCompanies.append(c)
            }
            self.portfolioCompanies = portfolioCompanies
            self.watchlistManager.setPortfolio(self.portfolioCompanies)
        }
    }
    
    private func loadWatchlist(){
        NetworkManager.getMyRestApi().listCompanies { companies in
            Dataholder.allTickers = companies
        }
        
        NetworkManager.getMyRestApi().getWatchlistForCurrentUser() { quotes in
            self.watchlist = self.watchlistManager.getWatchlist()
            if self.watchlist.count == 0 {
                DispatchQueue.main.async {
                    self.emptyView.isHidden = false
                }
                if self.watchlistUpdater == nil {
                    self.watchlistUpdater = WatchlistUpdater(caller: self, timeInterval: 60.0)
                    Dataholder.watchlistUpdater = self.watchlistUpdater
                    self.watchlistUpdater!.startWatchlistFetchingTimer()
                }
            } else {
                DispatchQueue.main.async {
                    self.emptyView.isHidden = true
                }
                for c in self.watchlist {
                    for q in quotes {
                        if (c.symbol == q.symbol) {
                            c.quote = q
                            break
                        }
                    }
                }
                self.watchlist.sort { a, b in
                    return (a.quote?.changePercent) ?? 0.0 > (b.quote?.changePercent) ?? 0.0
                }
                self.refreshData()
            }
        }
    }
    
    private func refreshData(){
        let now = Date().timeIntervalSince1970
        self.lastRefresh = now
        DispatchQueue.main.async {
            self.tableView.refreshControl!.beginRefreshing()

            if self.watchlist.count == 0 {
                self.emptyView.isHidden = false
            } else {
                self.emptyView.isHidden = true
            }
            self.tableView.reloadData()

            if !self.watchlist.isEmpty {
                if self.watchlistUpdater == nil {
                    self.watchlistUpdater = WatchlistUpdater(caller: self, timeInterval: 60.0)
                    Dataholder.watchlistUpdater = self.watchlistUpdater
                    self.watchlistUpdater!.startTask()
                }
            }
        }
            
        NetworkManager.getMyRestApi().getSelectedScore { score in
            self.selectedScoringSystem = score
            if self.selectedScoringSystem.isEmpty {
                self.selectedScoringSystem = "USER_CUSTOMIZED"
            }
            self.setSelectedScoreSystemLabel()
            NetworkManager.getMyRestApi().getPackageDataForSymbols(self.watchlistManager.getAllTickers(), packageId: self.selectedScoringSystem, completionHandler: self.savePremiumData)
            }
    }
    
    func setSelectedScoreSystemLabel(){
        DispatchQueue.main.async {
            if Constants.nonPremiumScoreIds[self.selectedScoringSystem] != nil {
                self.selectedScoreSystemLabel.text = Constants.nonPremiumScoreIds[self.selectedScoringSystem]
            } else {
                self.selectedScoreSystemLabel.text = Constants.premiumPackageNames[self.selectedScoringSystem]
            }
        }
    }
    
    private func savePremiumData(_ json:JSON){
        self.scoreDict = [:]
        switch self.selectedScoringSystem {
            
        case "USER_CUSTOMIZED":
            var scores:[SimpleScore] = []
            for i in 0..<json.count{
                let JSONString:String = json[i].rawString()!
                if let n = Mapper<SimpleScore>().map(JSONString: JSONString){
                    scores.append(n)
                    for company in self.watchlist {
                        if n.symbol == company.symbol {
                            company.simpleScore = n
                            self.scoreDict[n.symbol!] = (String(n.rank ?? -1), n.percentile ?? -1)
                            break
                        }
                    }
                    for company in self.portfolioCompanies {
                        if n.symbol == company.symbol {
                            company.simpleScore = n
                            self.scoreDict[n.symbol!] = (String(n.rank ?? -1), n.percentile ?? -1)
                            break
                        }
                    }
                }
            }
            break
        case "ANALYST_RECOMMENDATIONS":
            var dic:[String:Recommendations] = [:]
            for (symbol, data):(String, JSON) in json {
                let recommendationsJSON = data.rawString()!
                let recommendations:Recommendations = Mapper<Recommendations>().map(JSONString: recommendationsJSON) ?? Recommendations()
                dic[symbol] = recommendations
                for company in self.watchlist {
                    if symbol == company.symbol {
                        company.recommendations = recommendations
                        self.scoreDict[symbol] = (String(recommendations.ratingScaleMark ?? -1), recommendations.ratingScaleMark ?? -1)
                        if let s = recommendations.ratingScaleMark {
                            let percentile = (3 - s)/2
                            self.scoreDict[symbol] = (String(format: "%.1f", recommendations.ratingScaleMark ?? -1), percentile)
                        }
                        break
                    }
                }
                for company in self.portfolioCompanies {
                    if symbol == company.symbol {
                        company.recommendations = recommendations
                        self.scoreDict[symbol] = (String(recommendations.ratingScaleMark ?? -1), recommendations.ratingScaleMark ?? -1)
                        if let s = recommendations.ratingScaleMark {
                            let percentile = (3 - s)/2
                            self.scoreDict[symbol] = (String(format: "%.1f", recommendations.ratingScaleMark ?? -1), percentile)
                        }
                        break
                    }
                }
            }
            break
        case "ANALYST_PRICE_TARGET_UPSIDE":
            var dic:[String:PriceTarget] = [:]
            for (symbol, data):(String, JSON) in json {
                let priceTargetJSON = data.rawString()!
                let priceTarget:PriceTarget = Mapper<PriceTarget>().map(JSONString: priceTargetJSON) ?? PriceTarget()
                dic[symbol] = priceTarget
                for company in self.watchlist {
                    if symbol == company.symbol {
                        company.priceTarget = priceTarget
                        if let q = company.quote?.latestPrice, let avg = priceTarget.priceTargetAverage {
                            let upside = ((avg - q) / q) * 100.0
                            self.scoreDict[symbol] = (String(format: "%.0f", upside) + "%", upside / 50.0)
                        }
                        break
                    }
                }
                for company in self.portfolioCompanies {
                    if symbol == company.symbol {
                        company.priceTarget = priceTarget
                        if let q = company.quote?.latestPrice, let avg = priceTarget.priceTargetAverage {
                            let upside = ((avg - q) / q) * 100.0
                            self.scoreDict[symbol] = (String(format: "%.0f", upside) + "%", upside / 50.0)
                        }
                        break
                    }
                }
            }
            break
        case "PREMIUM_KAVOUT_KSCORE":
            var dic:[String:Kscore] = [:]
            for (symbol, data):(String, JSON) in json {
                if let x = Mapper<Kscore>().map(JSONString: data.rawString()!){
                    dic[symbol] = x
                    for company in self.watchlist {
                        if symbol == company.symbol {
                            company.kscores = x
                            if let score = x.kscore {
                                self.scoreDict[symbol] = (String(score), Double(score)/9.0)
                            }
                            break
                        }
                    }
                    for company in self.portfolioCompanies {
                        if symbol == company.symbol {
                            company.kscores = x
                            if let score = x.kscore {
                                self.scoreDict[symbol] = (String(score), Double(score)/9.0)
                            }
                            break
                        }
                    }
                }
            }
            break
        case "PREMIUM_BRAIN_RANKING_21_DAYS":
            var dic:[String:Brain21DayRanking] = [:]
            for (symbol, data):(String, JSON) in json {
                if let x = Mapper<Brain21DayRanking>().map(JSONString: data.rawString()!){
                    dic[symbol] = x
                    for company in self.watchlist {
                        if symbol == company.symbol {
                            company.brainRanking = x
                            if let score = x.mlAlpha {
                                let upside = score * 100.0
                                self.scoreDict[symbol] = (String(format: "%.1f", upside) + "%", upside / 10.0)
                            }
                            break
                        }
                    }
                    for company in self.portfolioCompanies {
                        if symbol == company.symbol {
                            company.brainRanking = x
                            if let score = x.mlAlpha {
                                let upside = score * 100.0
                                self.scoreDict[symbol] = (String(format: "%.1f", upside) + "%", upside / 10.0)
                            }
                            break
                        }
                    }
                }
            }
            break
        case "PREMIUM_BRAIN_SENTIMENT_30_DAYS":
            var dic:[String:BrainSentiment] = [:]
            for (symbol, data):(String, JSON) in json {
                if let x = Mapper<BrainSentiment>().map(JSONString: data.rawString()!){
                    dic[symbol] = x
                    for company in self.watchlist {
                        if symbol == company.symbol {
                            company.brainSentiment = x
                            if let score = x.sentimentScore {
                                let percentile = (1 - abs(score)) / 2
                                self.scoreDict[symbol] = (String(format: "%.1f", score), percentile)
                            }
                            break
                        }
                    }
                    for company in self.portfolioCompanies {
                        if symbol == company.symbol {
                            company.brainSentiment = x
                            if let score = x.sentimentScore {
                                let percentile = (1 - abs(score)) / 2
                                self.scoreDict[symbol] = (String(format: "%.1f", score), percentile)
                            }
                            break
                        }
                    }
                }
            }
            break
        case "STOCKTWITS_SENTIMENT":
            var dic:[String:StocktwitsSentiment] = [:]
            for (symbol, data):(String, JSON) in json {
                if let x = Mapper<StocktwitsSentiment>().map(JSONString: data.rawString()!){
                    dic[symbol] = x
                    for company in self.watchlist {
                        if symbol == company.symbol {
                            company.stocktwitsSentiment = x
                            if let score = x.sentiment {
                                let percentile = (1 - abs(score)) / 2
                                self.scoreDict[symbol] = (String(format: "%.1f", score), percentile)
                            }
                            break
                        }
                    }
                    for company in self.portfolioCompanies {
                        if symbol == company.symbol {
                            company.stocktwitsSentiment = x
                            if let score = x.sentiment {
                                let percentile = (1 - abs(score)) / 2
                                self.scoreDict[symbol] = (String(format: "%.1f", score), percentile)
                            }
                            break
                        }
                    }
                }
            }
            break
        case "PREMIUM_PRECISION_ALPHA_PRICE_DYNAMICS":
            var dic:[String:PrecisionAlphaDynamics] = [:]
            for (symbol, data):(String, JSON) in json {
                if let x = Mapper<PrecisionAlphaDynamics>().map(JSONString: data.rawString()!){
                    dic[symbol] = x
                    for company in self.watchlist {
                        if symbol == company.symbol {
                            company.precisionAlpha = x
                            if let score = x.probabilityUp {
                                let percentile = score * 100.0
                                self.scoreDict[symbol] = (String(format: "%.0f", percentile) + "%", (score - 40.0) / 20.0)
                            }
                            break
                        }
                    }
                    for company in self.portfolioCompanies {
                        if symbol == company.symbol {
                            company.precisionAlpha = x
                            if let score = x.probabilityUp {
                                let percentile = score * 100.0
                                self.scoreDict[symbol] = (String(format: "%.0f", percentile) + "%", (score - 40.0) / 20.0)
                            }
                            break
                        }
                    }
                }
            }
            break
        case "TOP_ANALYSTS_SCORES":
            var dic:[String:PriceTargetTopAnalysts] = [:]
            for (symbol, data):(String, JSON) in json {
                let JSONString:String = data.rawString()!
                if let n = Mapper<PriceTargetTopAnalysts>().map(JSONString: JSONString){
                    dic[symbol] = n
                    for company in self.watchlist {
                        if symbol == company.symbol {
                            company.priceTargetTopAnalysts = n
                            if let avg = n.avgPriceTarget, let q = company.quote?.latestPrice {
                                let upside = ((avg - q) / q) * 100.0
                                self.scoreDict[symbol] = (String(format: "%.0f", upside) + "%", upside / 50.0)
                            }
                            break
                        }
                    }
                    for company in self.portfolioCompanies {
                        if symbol == company.symbol {
                            company.priceTargetTopAnalysts = n
                            if let avg = n.avgPriceTarget, let q = company.quote?.latestPrice {
                                let upside = ((avg - q) / q) * 100.0
                                self.scoreDict[symbol] = (String(format: "%.0f", upside) + "%", upside / 50.0)
                            }
                            break
                        }
                    }
                }
            }
            break
        default:
            break
        }
        DispatchQueue.main.async {
            self.tableView.refreshControl!.endRefreshing()
            self.tableView.reloadData()
            self.portfolioTableGain.reloadData()
            self.portfolioTableChange.reloadData()
        }
    }
    
    public func updateFromScheduledTask(_ data:Any?){
        if !self.firstUpdateDone {
            self.firstUpdateDone = true
            DispatchQueue.main.async {
                self.activityIndicator.isHidden = true
            }
        }
        var watchlistRetrieved:Bool = false
        if self.watchlist.count == 0 {
            self.watchlist = self.watchlistManager.getWatchlist()
            if self.watchlist.count > 0 {
                watchlistRetrieved = true
                self.watchlistUpdater?.stopWatchlistFetchingTimer()
            }
        }
        
        let watchlist = self.watchlist
        //all of this logic is about setting whether the watchlist updater is hibernating or not hibernating means the WU will not fetch quotes
        //Checking for nil quotes is unnecessary if we force the WU to fetch quotes immediately after adding a stock to our WL
        if watchlist.isEmpty {
            self.watchlistUpdater?.hibernating = true
        } else {
            var anySymbolNeedsQuote = false
            for symbol in watchlist {
                if symbol.quote == nil {
                    anySymbolNeedsQuote = true
                }
            }
            if anySymbolNeedsQuote {
                self.watchlistUpdater?.hibernating = false
            } else {
                //no symbols need quote
                if Dataholder.isUSMarketOpen {
                    self.watchlistUpdater?.hibernating = false
                } else {
//                    self.watchlistUpdater?.hibernating = true
                }
            }
        }
        
        for pc in self.portfolioCompanies {
            self.portfolioQuoteLookup[pc.symbol] = pc.quote
        }
        
        if self.currentSort == "CHANGE" {
            if self.sortAsc {
                self.watchlist.sort { a, b in
                    return (a.quote?.changePercent) ?? 0.0 < (b.quote?.changePercent) ?? 0.0
                }
                self.portfolioCompanies.sort { a, b in
                    return (a.quote?.changePercent) ?? 0.0 < (b.quote?.changePercent) ?? 0.0
                }
            } else {
                self.watchlist.sort { a, b in
                    return (a.quote?.changePercent) ?? 0.0 > (b.quote?.changePercent) ?? 0.0
                }
                self.portfolioCompanies.sort { a, b in
                    return (a.quote?.changePercent) ?? 0.0 > (b.quote?.changePercent) ?? 0.0
                }
            }
        }
        
        self.gainSort()
        
        var dayPLTotal = 0.0
        for h in self.holdings {
            if let quote = self.portfolioQuoteLookup[h.symbol ?? ""] {
                let curVal = (h.quantity ?? 0.0) * (quote.latestPrice ?? 0.0)
                let dayGain = curVal - (curVal/(1+(((quote.changePercent ?? 0.0)/100.0) ?? 0.0)))
                dayPLTotal += dayGain
            }
        }
        DispatchQueue.main.async {
            self.dayPL.text = String(format: "%0.1f", dayPLTotal)
            if dayPLTotal > 0 {
                self.dayPL.textColor = Constants.green
            } else {
                self.dayPL.textColor = Constants.darkPink
            }
        }
        
        DispatchQueue.main.async {
            if watchlistRetrieved {
                self.refreshData()
            } else {
                self.tableView.reloadData()
                self.portfolioTableGain.reloadData()
                self.portfolioTableChange.reloadData()
            }
        }
    }
     
    @objc func handleRefresh() {
        let now = Date().timeIntervalSince1970
        if now - self.lastRefresh > 60.0 {
            self.refreshData()
        } else {
            self.tableView.refreshControl!.endRefreshing()
        }
    }
    
    public func shadowButtonTapped(_ premiumPackage: PremiumPackage?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let purchaseVC = storyboard.instantiateViewController(withIdentifier: "purchaseCreditsVC") as! PurchaseViewController
        self.present(purchaseVC, animated: true, completion: nil)
    }
    
//    public func creditBalanceUpdated() {
//        DispatchQueue.main.async {
//            self.creditBalanceView.credits.text = String("\(Dataholder.getCreditBalance())")
//        }
//    }
    
    //isnt called currently
    public func watchlistUpdated() {
        self.watchlist = self.watchlistManager.getWatchlist()
        self.refreshData()
        
        if let wu = self.watchlistUpdater {
            wu.hibernating = false
            wu.update()
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @IBAction func addToWatchlistButton(_ sender: Any) {
        self.tabBarController?.selectedIndex = 1
    }
    
    @IBAction func symbolSort(_ sender: Any) {
        if self.currentSort == "SYMBOL" {
            if self.sortAsc {
                self.watchlist.sort { a, b in
                    return (a.quote?.symbol) ?? "" > (b.quote?.symbol) ?? ""
                }
            } else {
                self.watchlist.sort { a, b in
                    return (a.quote?.symbol) ?? "" < (b.quote?.symbol) ?? ""
                }
            }
            self.sortAsc = !self.sortAsc
        } else {
            self.watchlist.sort { a, b in
                return (a.quote?.symbol) ?? "" < (b.quote?.symbol) ?? ""
            }
            self.currentSort = "SYMBOL"
            self.sortAsc = true
        }
        self.tableView.reloadData()
    }
    @IBAction func symbolSortPortfolio(_ sender: Any) {
        if self.currentSort == "SYMBOL" {
            if self.sortAsc {
                self.portfolioCompanies.sort { a, b in
                    return (a.quote?.symbol) ?? "" > (b.quote?.symbol) ?? ""
                }
            } else {
                self.portfolioCompanies.sort { a, b in
                    return (a.quote?.symbol) ?? "" < (b.quote?.symbol) ?? ""
                }
            }
            self.sortAsc = !self.sortAsc
        } else {
            self.portfolioCompanies.sort { a, b in
                return (a.quote?.symbol) ?? "" < (b.quote?.symbol) ?? ""
            }
            self.currentSort = "SYMBOL"
            self.sortAsc = true
        }
        self.portfolioTableChange.reloadData()
    }
    @IBAction func scoreSort(_ sender: Any) {
        
    }
    @IBAction func changeSort(_ sender: Any) {
        if self.currentSort == "CHANGE" {
            if self.sortAsc {
                self.watchlist.sort { a, b in
                    return (a.quote?.changePercent) ?? 0.0 > (b.quote?.changePercent) ?? 0.0
                }
            } else {
                self.watchlist.sort { a, b in
                    return (a.quote?.changePercent) ?? 0.0 < (b.quote?.changePercent) ?? 0.0
                }
            }
            self.sortAsc = !self.sortAsc
        } else {
            self.watchlist.sort { a, b in
                return (a.quote?.changePercent) ?? 0.0 < (b.quote?.changePercent) ?? 0.0
            }
            self.currentSort = "CHANGE"
            self.sortAsc = true
        }
        self.tableView.reloadData()
    }
    @IBAction func changeSortPortfolio(_ sender: Any) {
        if self.currentSort == "CHANGE" {
            if self.sortAsc {
                self.portfolioCompanies.sort { a, b in
                    return (a.quote?.changePercent) ?? 0.0 > (b.quote?.changePercent) ?? 0.0
                }
            } else {
                self.portfolioCompanies.sort { a, b in
                    return (a.quote?.changePercent) ?? 0.0 < (b.quote?.changePercent) ?? 0.0
                }
            }
            self.sortAsc = !self.sortAsc
        } else {
            self.portfolioCompanies.sort { a, b in
                return (a.quote?.changePercent) ?? 0.0 < (b.quote?.changePercent) ?? 0.0
            }
            self.currentSort = "CHANGE"
            self.sortAsc = true
        }
        self.portfolioTableChange.reloadData()
    }
    
    func gainSort(){
        if self.currentGainSort == "DAY" {
            if self.gainSortAsc {
                self.holdings.sort { a, b in
                    let quoteA = self.portfolioQuoteLookup[a.symbol ?? ""]
                    let quoteB = self.portfolioQuoteLookup[b.symbol ?? ""]
                    let dayGainA = (((quoteA?.changePercent ?? 0.0) / 100.0) ?? 0.0) * (a.quantity ?? 0.0) * (quoteA?.previousClose ?? 0.0)
                    let dayGainB = (((quoteB?.changePercent ?? 0.0) / 100.0) ?? 0.0) * (b.quantity ?? 0.0) * (quoteB?.previousClose ?? 0.0)
                    return dayGainA < dayGainB
                }
            } else {
                self.holdings.sort { a, b in
                    let quoteA = self.portfolioQuoteLookup[a.symbol ?? ""]
                    let quoteB = self.portfolioQuoteLookup[b.symbol ?? ""]
                    let dayGainA = (((quoteA?.changePercent ?? 0.0) / 100.0) ) * (a.quantity ?? 0.0) * (quoteA?.previousClose ?? 0.0)
                    let dayGainB = (((quoteB?.changePercent ?? 0.0) / 100.0) ) * (b.quantity ?? 0.0) * (quoteB?.previousClose ?? 0.0)
                    return dayGainA > dayGainB
                }
            }
        } else if self.currentGainSort == "TOTAL" {
            if self.gainSortAsc {
                self.holdings.sort { a, b in
                    let quoteA = self.portfolioQuoteLookup[a.symbol ?? ""]
                    let quoteB = self.portfolioQuoteLookup[b.symbol ?? ""]
                    let totalGainA = ((a.quantity ?? 0.0) * (quoteA?.latestPrice ?? 0.0)) - (a.cost_basis ?? 0.0)
                    let totalGainB = ((b.quantity ?? 0.0) * (quoteB?.latestPrice ?? 0.0)) - (b.cost_basis ?? 0.0)
                    return totalGainA < totalGainB
                }
            } else {
                self.holdings.sort { a, b in
                    let quoteA = self.portfolioQuoteLookup[a.symbol ?? ""]
                    let quoteB = self.portfolioQuoteLookup[b.symbol ?? ""]
                    let totalGainA = ((a.quantity ?? 0.0) * (quoteA?.latestPrice ?? 0.0)) - (a.cost_basis ?? 0.0)
                    let totalGainB = ((b.quantity ?? 0.0) * (quoteB?.latestPrice ?? 0.0)) - (b.cost_basis ?? 0.0)
                    return totalGainA > totalGainB
                }
            }
        } else if self.currentGainSort == "SYMBOL" {
            //sort by symbol
            if self.gainSortAsc {
                self.holdings.sort { a, b in
                    return (a.symbol ?? "") > (b.symbol ?? "")
                }
            } else {
                self.holdings.sort { a, b in
                    return (a.symbol ?? "") < (b.symbol ?? "")
                }
            }
        } else if self.currentGainSort == "VALUE" {
            if self.gainSortAsc {
                self.holdings.sort { a, b in
                    let quoteA = self.portfolioQuoteLookup[a.symbol ?? ""]
                    let quoteB = self.portfolioQuoteLookup[b.symbol ?? ""]
                    let valA = ((a.quantity ?? 0.0) * (quoteA?.latestPrice ?? 0.0))
                    let valB = ((b.quantity ?? 0.0) * (quoteB?.latestPrice ?? 0.0))
                    return valA < valB
                }
            } else {
                self.holdings.sort { a, b in
                    let quoteA = self.portfolioQuoteLookup[a.symbol ?? ""]
                    let quoteB = self.portfolioQuoteLookup[b.symbol ?? ""]
                    let valA = ((a.quantity ?? 0.0) * (quoteA?.latestPrice ?? 0.0))
                    let valB = ((b.quantity ?? 0.0) * (quoteB?.latestPrice ?? 0.0))
                    return valA > valB
                }
            }
        }
    }
    
    @IBAction func gainSortSymbol(_ sender: Any) {
        let oldSort = self.currentGainSort
        self.currentGainSort = "SYMBOL"
        if oldSort != self.currentGainSort {
            self.gainSortAsc = true
        } else {
            self.gainSortAsc = !self.gainSortAsc
        }
        self.gainSort()
        self.portfolioTableGain.reloadData()
    }
    
    @IBAction func gainSortDay(_ sender: Any) {
        let oldSort = self.currentGainSort
        self.currentGainSort = "DAY"
        if oldSort != self.currentGainSort {
            self.gainSortAsc = true
        } else {
            self.gainSortAsc = !self.gainSortAsc
        }
        self.gainSort()
        self.portfolioTableGain.reloadData()
    }
    @IBAction func gainSortTotal(_ sender: Any) {
        let oldSort = self.currentGainSort
        self.currentGainSort = "TOTAL"
        if oldSort != self.currentGainSort {
            self.gainSortAsc = true
        } else {
            self.gainSortAsc = !self.gainSortAsc
        }
        self.gainSort()
        self.portfolioTableGain.reloadData()
    }
    @IBAction func gainSortValue(_ sender: Any) {
        let oldSort = self.currentGainSort
        self.currentGainSort = "VALUE"
        if oldSort != self.currentGainSort {
            self.gainSortAsc = true
        } else {
            self.gainSortAsc = !self.gainSortAsc
        }
        self.gainSort()
        self.portfolioTableGain.reloadData()
    }
    //copied from watchlisttvcell
    //val is number between 0 and 1
    func getScoreTextColor(_ val:Double) -> UIColor {
        if val == -1 {
            return .clear
        }
        let blue:CGFloat = 0.0
        var red:CGFloat = 0.0
        var green:CGFloat = 0.0
        if val <= 0.5 {
            red = 218.0
            green = CGFloat((val/0.5) * 218.0)
        } else {
            green = 218.0
            red = CGFloat(218.0 - ((val - 0.5)/0.5) * 218.0)
        }
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1.0)
    }
    
    
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//    }
}

/* TableView functions */
extension WatchlistVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.restorationIdentifier == "watchlistTable" {
            return self.watchlist.count
        } else if tableView.restorationIdentifier == "PortfolioTableChange" {
            return self.portfolioCompanies.count
        } else {
            //PortfolioTableGain
            return self.holdings.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.restorationIdentifier == "watchlistTable" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "watchListCell", for: indexPath) as! WatchlistTVCell
            if self.watchlist.count > indexPath.row {
                let company = self.watchlist[indexPath.row]
                if let scores = self.scoreDict[company.symbol]{
                    cell.displayData(company: company, score: scores.0, percentile: scores.1)
                } else {
                    cell.displayData(company: company, score: "", percentile: -1)
                }
            }
            return cell
        } else if tableView.restorationIdentifier == "PortfolioTableChange" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "watchlistCellPortfolio", for: indexPath) as! WatchlistTVCell
            if self.portfolioCompanies.count > indexPath.row {
                let company = self.portfolioCompanies[indexPath.row]
                if let scores = self.scoreDict[company.symbol]{
                    cell.displayData(company: company, score: scores.0, percentile: scores.1)
                } else {
                    cell.displayData(company: company, score: "", percentile: -1)
                }
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "portfolioGainCell", for: indexPath) as! PortfolioGainTableViewCell
            let holding:Holding = self.holdings[indexPath.row]
            
            //find matching company
            for i in 0..<self.portfolioCompanies.count {
                let c = self.portfolioCompanies[i]
                if c.symbol == (holding.symbol ?? "") {
                    cell.daysToEarnings.text = ""
                    cell.erImage.isHidden = true
                    //always hide er image here because we have less space in this table
//                    if let ea:Int = c.quote?.daysToEarnings {
//                        if ea > 0 && ea < 6 {
//                            cell.erImage.isHidden = false
//                            cell.daysToEarnings.text = String(ea) + "d"
//                        }
//                    }
                    
                    if let q = c.quote, let change = c.quote?.changePercent, let p = c.quote?.latestPrice, let cb = holding.cost_basis, let quant = holding.quantity {
                        let curVal = quant * p
                        cell.dayGain.text = String(format: "%0.1f", curVal - (curVal/(1 + (change/100.0))))
                        cell.dayGainPercent.text = String(format: "%0.1f%%", change)
                        cell.totalGain.text = String(format: "%0.1f", curVal - cb)
                        cell.totalGainPercent.text = String(format: "%0.1f%%", ((curVal - cb)/cb) * 100.0)
                        cell.currentValue.text = String(format: "$%0.1f", curVal)
                        
                        if self.totalPortValue > 0.0 {
                            cell.percentPort.text = String(format: "%0.2f%%", (curVal/self.totalPortValue) * 100.0)
                        }
      
                        cell.numShares.text = String(format: "%0.1f", quant)
                        cell.cbs.text = String(format: "@ $%0.1f", cb / quant)
                        
                        if (curVal - (curVal/(1 + (change/100.0)))) >= 0 {
                            cell.dayGain.textColor = Constants.green
                            cell.dayGainPercent.textColor = Constants.green
                        } else {
                            cell.dayGain.textColor = Constants.darkPink
                            cell.dayGainPercent.textColor = Constants.darkPink
                        }
                        if (curVal - cb) >= 0 {
                            cell.totalGain.textColor = Constants.green
                            cell.totalGainPercent.textColor = Constants.green
                        } else {
                            cell.totalGain.textColor = Constants.darkPink
                            cell.totalGainPercent.textColor = Constants.darkPink
                        }
                    }
                    break
                }
            }
            
            cell.ticker.text = holding.symbol ?? ""
            cell.companyName.text = holding.name ?? ""
            
            cell.buyRating.backgroundColor = .clear
            cell.buyRating.text = " "
            if let scores = self.scoreDict[holding.symbol ?? ""]{
                let percentile = scores.1
                let score = scores.0
                if percentile == -1 {
                    cell.buyRating.backgroundColor = .clear
                } else {
                    cell.buyRating.backgroundColor = self.getScoreTextColor(percentile).withAlphaComponent(0.2)
                }
                cell.buyRating.textColor = self.getScoreTextColor(percentile)
                cell.buyRating.text = " " + score + "  "
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if tableView.restorationIdentifier == "PortfolioTableChange" || tableView.restorationIdentifier == "PortfolioTableGain" {
            return false
        }
        return true
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if tableView.restorationIdentifier == "watchlistTable" {
            if editingStyle == .delete {
                var c = self.watchlist[indexPath.row]
                self.watchlistManager.removeCompanyBySymbol(symbol: c.symbol){}
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.restorationIdentifier == "watchlistTable" {
            Dataholder.selectedCompany = self.watchlist[indexPath.row]
        } else if tableView.restorationIdentifier == "PortfolioTableChange" {
            Dataholder.selectedCompany = self.portfolioCompanies[indexPath.row]
        } else if tableView.restorationIdentifier == "PortfolioTableGain" {
            let holding = self.holdings[indexPath.row]
            for c in self.portfolioCompanies {
                if (c.symbol ?? "") == (holding.symbol ?? "") {
                    Dataholder.selectedCompany = c
                    break
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if tableView.restorationIdentifier == "watchlistTable" {
            Dataholder.selectedCompany = self.watchlist[indexPath.row]
        } else if tableView.restorationIdentifier == "PortfolioTableChange" {
            Dataholder.selectedCompany = self.portfolioCompanies[indexPath.row]
        } else if tableView.restorationIdentifier == "PortfolioTableGain" {
            let holding = self.holdings[indexPath.row]
            for c in self.portfolioCompanies {
                if (c.symbol ?? "") == (holding.symbol ?? "") {
                    Dataholder.selectedCompany = c
                    break
                }
            }
        }
        return indexPath
    }
    
}
