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

class WatchlistVC: UIViewController, Updateable, ShadowButtonDelegate {
    
    @IBOutlet weak var creditBalanceView: ShadowButtonView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerBgView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var watchlistUpdater: WatchlistUpdater?
    private var watchlistManager:WatchlistManager!
    private var firstUpdateDone:Bool = false
    
    @IBOutlet weak var selectedScoreSystemLabel: UILabel!
    private var selectedScoringSystem:String = ""
    private var scoreDict:[String:(String, Double)] = [:]
    
    @IBOutlet weak var emptyView: UIView!
    
    private var lastRefresh:Double = 0
    private var watchlist:[Company] = []
    private var currentSort:String = "CHANGE"
    private var sortAsc:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.activityIndicator.startAnimating()
        self.activityIndicator.isHidden = true
        
        Dataholder.subscribeForCreditBalanceUpdates(self)
        self.creditBalanceView.delegate = self
        self.creditBalanceView.bgColor = Constants.orange
        self.creditBalanceView.shadColor = UIColor(red: 100.0/255.0, green: 60.0/255.0, blue: 25.0/255.0, alpha: 1.0).cgColor
        self.headerBgView.addGradientBackground()
        
        self.watchlistManager = Dataholder.watchlistManager
        self.watchlistManager.watchlistVC = self
        self.watchlist = watchlistManager.getWatchlist()
        
        self.headerBgView.layer.shadowColor = UIColor.black.cgColor
        self.headerBgView.layer.shadowOpacity = 0.7
        self.headerBgView.layer.shadowOffset = .zero
        self.headerBgView.layer.shadowRadius = 3
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorInset = UIEdgeInsets.zero
        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl!.addTarget(self, action: #selector(handleRefresh), for: UIControl.Event.valueChanged)
        
        self.tableView.backgroundView = nil
        self.tableView.backgroundColor = UIColor.white
        
        NetworkManager.getMyRestApi().getCreditsForCurrentUser { credits in
            Dataholder.updateCreditBalance(credits)
        }
        self.loadWatchlist()
        
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
        self.creditBalanceView.credits.text = String("\(Dataholder.getCreditBalance())")
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //do we stop the watchlist updater while not on the watchlist? or just always have it going for simplicity?
    }
    
    private func loadWatchlist(){
        NetworkManager.getMyRestApi().listCompanies { companies in
            Dataholder.allTickers = companies
        }
        
        NetworkManager.getMyRestApi().getWatchlistForCurrentUser() { quotes in
            self.watchlist = self.watchlistManager.getWatchlist()
            if self.watchlist.count == 0 {
                if self.watchlistUpdater == nil {
                    self.watchlistUpdater = WatchlistUpdater(caller: self, timeInterval: 60.0)
                    Dataholder.watchlistUpdater = self.watchlistUpdater
                    self.watchlistUpdater!.startWatchlistFetchingTimer()
                }
            } else {
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
            NetworkManager.getMyRestApi().getPackageDataForSymbols(self.watchlistManager.getTickers(), packageId: self.selectedScoringSystem, completionHandler: self.savePremiumData)
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
                            let upside = ((avg - q) / avg) * 100.0
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
                }
            }
            break
        default:
            break
        }
        DispatchQueue.main.async {
            self.tableView.refreshControl!.endRefreshing()
            self.tableView.reloadData()
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
        
        if self.currentSort == "CHANGE" {
            if self.sortAsc {
                self.watchlist.sort { a, b in
                    return (a.quote?.changePercent) ?? 0.0 < (b.quote?.changePercent) ?? 0.0
                }
            } else {
                self.watchlist.sort { a, b in
                    return (a.quote?.changePercent) ?? 0.0 > (b.quote?.changePercent) ?? 0.0
                }
            }
        }
        DispatchQueue.main.async {
            if watchlistRetrieved {
                self.refreshData()
            } else {
                self.tableView.reloadData()
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
    
    public func creditBalanceUpdated() {
        DispatchQueue.main.async {
            self.creditBalanceView.credits.text = String("\(Dataholder.getCreditBalance())")
        }
    }
    
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
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//    }
}

/* TableView functions */
extension WatchlistVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.watchlist.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.watchlistManager.removeCompanyByIndex(index: indexPath.row){}
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Dataholder.selectedCompany = self.watchlist[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        Dataholder.selectedCompany = self.watchlist[indexPath.row]
        return indexPath
    }
    
}
