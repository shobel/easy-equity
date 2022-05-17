//
//  CompanySearchTVC.swift
//  stonks
//
//  Created by Samuel Hobel on 9/30/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import UIKit
import SafariServices
import XLActionController

extension CompanySearchVC: UISearchBarDelegate, LoadingProtocol {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterList(searchText: searchText.uppercased())
        self.tableView.reloadData()
        if self.searchResults.count > 0 {
            DispatchQueue.main.async {
                self.scrollView.setContentOffset(.zero, animated: false)
            }
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.dismiss(animated: true, completion: nil)
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }
}

extension CompanySearchVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.restorationIdentifier == "top10" {
            return currentTop10List.count
        } else if collectionView.restorationIdentifier == "topAnalysts" {
            return currentTopAnalystSymbols.count
        } else if collectionView.restorationIdentifier == "marketNewsCollection" {
            return marketNews.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.restorationIdentifier == "top10" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "top10cell", for: indexPath) as! Top10CollectionViewCell
            let item = currentTop10List[indexPath.row]
            cell.symbolLabel.text = item.symbol
            cell.changePercentLabel.setValue(value: item.changePercent, isPercent: true)
            cell.latestPriceLabel.text = String("\(item.latestPrice)")
            cell.latestPriceLabel.textColor = cell.changePercentLabel.getColor(value: item.changePercent)
            return cell
        } else if collectionView.restorationIdentifier == "marketNewsCollection" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "marketNewsCollectionCell", for: indexPath) as! MarketNewsCollectionViewCell
            let news:News = self.marketNews[indexPath.row]
            cell.heading.text = news.headline
            cell.date.text = news.date!
            let url = URL(string: news.image!)
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url!) {
                    DispatchQueue.main.async {
                        cell.newImage.image = UIImage(data: data)
                    }
                }
            }
            cell.source.text = news.source
            cell.symbols.text = news.related
            cell.url = news.url
            return cell
        } else if collectionView.restorationIdentifier == "topAnalysts"{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "topAnalystCell", for: indexPath) as! TopAnalystCollectionViewCell
            let item = currentTopAnalystSymbols[indexPath.row]
            cell.symbol.text = item.symbol
            if let upside = item.upsidePercent {
                cell.avgUpside.setValue(value: upside, isPercent: true)
            } else {
                cell.avgUpside.setValue(value: Double(Int.min), isPercent: true)
            }
            cell.avgRank.text = String(format: "%.1f", item.avgAnalystRank!)
            cell.numAnalysts.text = String(item.numAnalysts!)
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.restorationIdentifier == "top10" {
            let item = currentTop10List[indexPath.row]
            Dataholder.selectedCompany = Company(symbol: item.symbol, fullName: "")
            performSegue(withIdentifier: "SearchToDetail", sender: self)
        } else if collectionView.restorationIdentifier == "topAnalysts" {
            let item = currentTopAnalystSymbols[indexPath.row]
            Dataholder.selectedCompany = Company(symbol: item.symbol!, fullName: "")
            performSegue(withIdentifier: "SearchToDetail", sender: self)
        } else if collectionView.restorationIdentifier == "marketNewsCollection" {
            let marketNewsItem:News = self.marketNews[indexPath.row]
            let url = URL(string: marketNewsItem.url!)
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            if url != nil && (marketNewsItem.url?.starts(with: "http"))! {
                let vc = SFSafariViewController(url: url!, configuration: config)
                present(vc, animated: true)
            }
        }
    }
    
}

//TODO-SAM: when company search returns no results, might want to switch table views to show a message that says no results
class CompanySearchVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var mainView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    //@IBOutlet weak var marketNewsTableView: MarketNewsTableView!
    
    @IBOutlet weak var marketView: UIView!
    @IBOutlet weak var marketNewsCollection: UICollectionView!
    @IBOutlet weak var top10CollectionView: UICollectionView!
    @IBOutlet weak var topAnalystsCollection: UICollectionView!
    @IBOutlet weak var top10Title: UILabel!
    @IBOutlet weak var analystSort: UIButton!
    
    private var searchResults:[Company] = []
    private var activityIndicatorView: UIActivityIndicatorView!
    
    private var top10s:Top10s?
    private var currentTop10List:[SimpleQuote] = []
    private var priceTargetTopAnalysts:[PriceTargetTopAnalysts] = []
    private var currentTopAnalystSymbols:[PriceTargetTopAnalysts] = []
    private var maxNumTopAnalystItems:Int = 10
    private var marketNews:[News] = []
    @IBOutlet weak var noTopAnalystsLabel: UIButton!
    
    private var refreshControl:UIRefreshControl!
    
    private var itemsLoaded:Int = 0
    private var numItems:Int = 4
    private var lastLoadedTimestamp:Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainView.addPurpleGradientBackground()
        
        top10CollectionView.delegate = self
        top10CollectionView.dataSource = self
        topAnalystsCollection.delegate = self
        topAnalystsCollection.dataSource = self
        tableView.isHidden = true
        marketView.isHidden = false
        
        tableView.tableFooterView = UIView(frame: .zero)
        //marketNewsTableView.tableFooterView = UIView(frame: .zero)
        
        searchBar.autocapitalizationType = .none
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        //marketNewsTableView.delegate = self
        //marketNewsTableView.dataSource = self
        marketNewsCollection.delegate = self
        marketNewsCollection.dataSource = self
        
        activityIndicatorView = UIActivityIndicatorView(style: .large)
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.center = self.view.center
                
        self.scrollView.refreshControl = UIRefreshControl()
        self.scrollView.refreshControl!.attributedTitle = NSAttributedString(string: "refreshing...")
        self.scrollView.refreshControl!.addTarget(self, action: #selector(didPullToRefresh), for: UIControl.Event.valueChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.refreshAll()
    }
    
    @objc func didPullToRefresh(sender:AnyObject) {
        self.refreshAll()
    }
    
    //refreshes no more often than every 10 min
    private func refreshAll(){
        if Date().timeIntervalSince1970 - self.lastLoadedTimestamp > (60*10){
            self.lastLoadedTimestamp = Date().timeIntervalSince1970
            self.itemsLoaded = 0
            self.loadingStarted()
            NetworkManager.getMyRestApi().getTop10s(completionHandler: handleTop10s)
            NetworkManager.getMyRestApi().getMarketNews(completionHandler: handleMarketNews)
            NetworkManager.getMyRestApi().getTiprankSymbols("5", completionHandler: handleTopAnalysts)
//            NetworkManager.getMyRestApi().getStocktwitsPostsTrending(summary: "false", completionHandler: handleStocktwitsPosts)
            if Dataholder.allTickers.isEmpty {
                self.numItems += 1
                NetworkManager.getMyRestApi().listCompanies(completionHandler: handleListCompanies)
            }
        } else {
            if self.priceTargetTopAnalysts.count == 0 {
                NetworkManager.getMyRestApi().getTiprankSymbols("5", completionHandler: handleTopAnalysts)
            }
            self.scrollView.refreshControl!.endRefreshing()
            self.loadingFinished()
        }
    }
    
    @IBAction func sortTop10List(_ sender: Any) {
        if self.currentTop10List.count > 0 {
            self.top10CollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: true)
        }
        let actionController = SkypeActionController() //not really for skype
        actionController.addAction(Action("Top Gainers", style: .default, handler: { action in
            self.top10Title.text = "Top Gainers"
            self.currentTop10List = self.top10s?.gainers ?? []
            self.top10CollectionView.reloadData()
        }))
        actionController.addAction(Action("Top Losers", style: .default, handler: { action in
            self.top10Title.text = "Top Losers"
            self.currentTop10List = self.top10s?.losers ?? []
            self.top10CollectionView.reloadData()
        }))
        actionController.addAction(Action("Most Active", style: .default, handler: { action in
            self.top10Title.text = "Most Active"
            self.currentTop10List = self.top10s?.mostactive ?? []
            self.top10CollectionView.reloadData()
        }))
        present(actionController, animated: true, completion: nil)
    }
    
    @IBAction func sortTopAnalysts(_ sender: Any) {
        if self.priceTargetTopAnalysts.count == 0 {
            return
        }
        self.topAnalystsCollection.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: true)
        let actionController = SkypeActionController() //not really for skype
        actionController.addAction(Action("Upside Percentage", style: .default, handler: { action in
            self.priceTargetTopAnalysts = self.priceTargetTopAnalysts.sorted {
                return ($0.upsidePercent ?? Double(Int.min)) > ($1.upsidePercent ?? Double(Int.min))
            }
            self.currentTopAnalystSymbols = Array(self.priceTargetTopAnalysts.prefix(self.maxNumTopAnalystItems))
            self.currentTopAnalystSymbols = self.currentTopAnalystSymbols.filter({ p in
                p.upsidePercent != nil
            })
            self.topAnalystsCollection.reloadData()
        }))
        actionController.addAction(Action("Number of Analysts", style: .default, handler: { action in
            self.priceTargetTopAnalysts.sort { (p1, p2) -> Bool in
                return p1.numAnalysts! > p2.numAnalysts!
            }
            self.currentTopAnalystSymbols = Array(self.priceTargetTopAnalysts.prefix(self.maxNumTopAnalystItems))
            self.topAnalystsCollection.reloadData()
        }))
        actionController.addAction(Action("Average Analyst Rank", style: .default, handler: { action in
            self.priceTargetTopAnalysts.sort { (p1, p2) -> Bool in
                return p1.avgAnalystRank! < p2.avgAnalystRank!
            }
            self.currentTopAnalystSymbols = Array(self.priceTargetTopAnalysts.prefix(self.maxNumTopAnalystItems))
            self.topAnalystsCollection.reloadData()
        }))
        present(actionController, animated: true, completion: nil)
    }
    
    private func handleListCompanies(_ companies:[Company]) {
        Dataholder.allTickers = companies
        self.itemsLoaded += 1
        if self.itemsLoaded >= self.numItems {
            self.loadingFinished()
        }
    }
    
    private func handleMarketNews(_ news: [News]){
        self.marketNews = news
        DispatchQueue.main.async {
            //self.marketNewsTableView.reloadData()
            self.marketNewsCollection.reloadData()
        }
        self.itemsLoaded += 1
        if self.itemsLoaded >= self.numItems {
            self.loadingFinished()
        }
    }
    
    private func handleTop10s(_ top10s: Top10s){
        self.top10s = top10s
        self.top10s?.gainers.sort(by: { (q1, q2) -> Bool in
            return q1.changePercent > q2.changePercent
        })
        self.top10s?.losers.sort(by: { (q1, q2) -> Bool in
            return q1.changePercent < q2.changePercent
        })
        self.top10s?.mostactive.sort(by: { (q1, q2) -> Bool in
            return q1.changePercent > q2.changePercent
        })
        self.itemsLoaded += 1
        if self.itemsLoaded >= self.numItems {
            self.loadingFinished()
        }
        DispatchQueue.main.async {
            self.currentTop10List = self.top10s?.gainers ?? []
            self.top10CollectionView.reloadData()
        }
    }
    
    private func handleTopAnalysts(_ topAnalystSymbols:[PriceTargetTopAnalysts]) {
        self.priceTargetTopAnalysts = topAnalystSymbols
        self.priceTargetTopAnalysts.sort { (p1, p2) -> Bool in
            return p1.numAnalysts ?? 0 > p2.numAnalysts ?? 0
        }
        self.priceTargetTopAnalysts = self.priceTargetTopAnalysts.filter({ p in
            p.numAnalysts ?? 0 > 5
        })
        self.itemsLoaded += 1
        var symbolSet:Set<String> = []
        for a in self.priceTargetTopAnalysts {
            symbolSet.insert(a.symbol!)
        }
        if symbolSet.isEmpty {
            self.handleLatestQuotes(quotes: [])
        } else {
            NetworkManager.getMyRestApi().getQuotes(symbols: Array(symbolSet), completionHandler: handleLatestQuotes)
        }
    }
    
    private func handleLatestQuotes(quotes:[Quote]){
        var newAnalystSymbolList:[PriceTargetTopAnalysts] = []
        for var item in self.priceTargetTopAnalysts {
            for quote in quotes {
                if quote.symbol == item.symbol && item.avgPriceTarget != nil && quote.latestPrice != nil{
                    item.upsidePercent = ((item.avgPriceTarget! - quote.latestPrice!) / quote.latestPrice!) * 100.0
                    break
                }
            }
            newAnalystSymbolList.append(item)
        }
        self.priceTargetTopAnalysts = newAnalystSymbolList
        self.itemsLoaded += 1
        if self.itemsLoaded >= self.numItems {
            self.loadingFinished()
        }
        DispatchQueue.main.async {
            if self.priceTargetTopAnalysts.count == 0 {
                self.noTopAnalystsLabel.isHidden = false
                self.analystSort.isHidden = true
                self.topAnalystsCollection.isHidden = true
            } else {
                self.noTopAnalystsLabel.isHidden = true
                self.analystSort.isHidden = false
                self.topAnalystsCollection.isHidden = false
            }
            self.currentTopAnalystSymbols = Array(self.priceTargetTopAnalysts.prefix(self.maxNumTopAnalystItems))
//            self.currentTopAnalystSymbols = self.currentTopAnalystSymbols.filter({ p in
//                p.upsidePercent != nil
//            })
            self.topAnalystsCollection.reloadData()
        }
    }
    
    public func loadingStarted(){
        DispatchQueue.main.async {
            self.activityIndicatorView.startAnimating()
        }
    }
    public func loadingFinished(){
        DispatchQueue.main.async {
            self.scrollView.refreshControl!.endRefreshing()
            self.activityIndicatorView.stopAnimating()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView is MarketNewsTableView {
            return self.marketNews.count
        } else if tableView.restorationIdentifier == "searchTable" {
            return searchResults.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.restorationIdentifier == "searchTable" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "companySearchCell", for: indexPath) as! CompanySearchTableViewCell
            cell.parentVC = self
            let company = searchResults[indexPath.row]
            cell.symbol?.text = searchResults[indexPath.row].symbol
            cell.companyName?.text = company.fullName
            cell.company = company
            cell.backgroundColor = .clear
            if Dataholder.watchlistManager.getWatchlist().contains(company) {
                cell.addedToWatchlist(true)
            } else {
                cell.addedToWatchlist(false)
            }
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    private func filterList(searchText: String){
        if searchText == "" {
            searchResults = []
        } else {
            searchResults = Dataholder.allTickers.filter {
                $0.symbol.lowercased().starts(with: searchText.lowercased()) ||
                $0.fullName.lowercased().starts(with: searchText.lowercased())
            }
        }
        if searchResults.count > 0 {
            self.marketView.isHidden = true
            self.tableView.isHidden = false
        } else {
            self.marketView.isHidden = false
            self.tableView.isHidden = true
        }
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if !(tableView is MarketNewsTableView) {
            Dataholder.selectedCompany = searchResults[indexPath.row]
        }
        return indexPath
    }

    @IBAction func topAnalystsSubButton(_ sender: Any) {
        self.tabBarController?.selectedIndex = 3
    }
    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
    */

}
