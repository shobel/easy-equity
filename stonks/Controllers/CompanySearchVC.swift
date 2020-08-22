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

extension CompanySearchVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterList(searchText: searchText)
        self.tableView.reloadData()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension CompanySearchVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.restorationIdentifier == "top10" {
            return currentTop10List.count
        } else if collectionView.restorationIdentifier == "topAnalysts" {
            return currentTopAnalystSymbols.count
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
            cell.latestPriceLabel.text = String("$\(item.latestPrice)")
            cell.latestPriceLabel.textColor = cell.changePercentLabel.getColor(value: item.changePercent)
            self.buttonCompanyDict[cell.segueButton] = Company(symbol: item.symbol, fullName: item.companyName)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "topAnalystCell", for: indexPath) as! TopAnalystCollectionViewCell
            let item = currentTopAnalystSymbols[indexPath.row]
            cell.symbol.text = item.symbol
            cell.avgUpside.setValue(value: item.upsidePercent!, isPercent: true)
            cell.avgRank.text = String(format: "%.1f", item.avgAnalystRank!)
            cell.numAnalysts.text = String(item.numAnalysts!)
            self.buttonCompanyDict[cell.segueButton] = Company(symbol: item.symbol!, fullName: item.companyName!)
            return cell
        }
    }
    
}

class CompanySearchVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var marketNewsTableView: MarketNewsTableView!
    
    @IBOutlet weak var marketView: UIView!
    @IBOutlet weak var top10CollectionView: UICollectionView!
    @IBOutlet weak var topAnalystsCollection: UICollectionView!
    @IBOutlet weak var top10Title: UILabel!
    
    private var searchResults:[Company] = []
    private var activityIndicatorView: UIActivityIndicatorView!
    
    private var top10s:Top10s?
    private var currentTop10List:[SimpleQuote] = []
    private var priceTargetTopAnalysts:[PriceTargetTopAnalysts] = []
    private var currentTopAnalystSymbols:[PriceTargetTopAnalysts] = []
    private var maxNumTopAnalystItems:Int = 10
    private var marketNews:[News] = []
    private var buttonCompanyDict:[UIButton:Company] = [:]
    @IBOutlet weak var noTopAnalystsLabel: UILabel!
    
    private var itemsLoaded:Int = 0
    private var numItems:Int = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        top10CollectionView.delegate = self
        top10CollectionView.dataSource = self
        topAnalystsCollection.delegate = self
        topAnalystsCollection.dataSource = self
        tableView.isHidden = true
        marketView.isHidden = false
        
        tableView.tableFooterView = UIView(frame: .zero)
        marketNewsTableView.tableFooterView = UIView(frame: .zero)
        
        searchBar.autocapitalizationType = .none
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        marketNewsTableView.delegate = self
        marketNewsTableView.dataSource = self
        
        activityIndicatorView = UIActivityIndicatorView(style: .large)
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.center = self.view.center
        

        self.loadingStarted()
        NetworkManager.getMyRestApi().getTop10s(completionHandler: handleTop10s)
        NetworkManager.getMyRestApi().getMarketNews(completionHandler: handleMarketNews)
        NetworkManager.getMyRestApi().getTiprankSymbols(completionHandler: handleTopAnalysts)
        if Dataholder.allTickers.isEmpty {
            self.numItems += 1
            NetworkManager.getMyRestApi().listCompanies(completionHandler: handleListCompanies)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //
    }
    
    @IBAction func sortTop10List(_ sender: Any) {
        self.top10CollectionView.scrollToItem(at: IndexPath(item: 0, section: 1), at: .left, animated: true)
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
        self.topAnalystsCollection.scrollToItem(at: IndexPath(item: 0, section: 1), at: .left, animated: true)
        let actionController = SkypeActionController() //not really for skype
        actionController.addAction(Action("Upside Percentage", style: .default, handler: { action in
            self.priceTargetTopAnalysts.sort { (p1, p2) -> Bool in
                return p1.upsidePercent! > p2.upsidePercent!
            }
            self.currentTopAnalystSymbols = Array(self.priceTargetTopAnalysts.prefix(self.maxNumTopAnalystItems))
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
            self.marketNewsTableView.reloadData()
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
            return p1.upsidePercent! > p2.upsidePercent!
        }
        self.itemsLoaded += 1
        if self.itemsLoaded >= self.numItems {
            self.loadingFinished()
        }
        DispatchQueue.main.async {
            if self.priceTargetTopAnalysts.count == 0 {
                self.noTopAnalystsLabel.isHidden = false
                self.topAnalystsCollection.isHidden = true
            } else {
                self.noTopAnalystsLabel.isHidden = true
                self.topAnalystsCollection.isHidden = false
            }
            self.currentTopAnalystSymbols = Array(self.priceTargetTopAnalysts.prefix(self.maxNumTopAnalystItems))
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
            self.activityIndicatorView.stopAnimating()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView is MarketNewsTableView {
            return self.marketNews.count
        } else {
            return searchResults.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !(tableView is MarketNewsTableView) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "companySearchCell", for: indexPath) as! CompanySearchTableViewCell
            cell.parentVC = self
            let company = searchResults[indexPath.row]
            cell.symbol?.text = searchResults[indexPath.row].symbol
            cell.companyName?.text = company.fullName
            cell.company = company
            
            if Dataholder.watchlistManager.getWatchlist().contains(company) {
                cell.addedToWatchlist(true)
            } else {
                cell.addedToWatchlist(false)
            }
            return cell
        } else {
            let cell = marketNewsTableView.dequeueReusableCell(withIdentifier: "marketnewscell") as! MarketNewsTableViewCell
            let news:News = self.marketNews[indexPath.row]
            cell.heading.text = news.headline
            let date = Date(timeIntervalSince1970: Double(news.datetime! / 1000))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, yy"
            let localDate = dateFormatter.string(from: date)
            cell.date.text = localDate
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
            cell.paywall = news.hasPaywall!
            cell.url = news.url
            return cell
        }
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !(tableView is MarketNewsTableView) {
            Dataholder.selectedCompany = searchResults[indexPath.row]
        } else {
            let marketNewsItem:News = self.marketNews[indexPath.row]
            let url = URL(string: marketNewsItem.url!)
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            var vc = SFSafariViewController(url: URL(string: "https://www.google.com")!)
            if (marketNewsItem.url?.starts(with: "http"))! {
                vc = SFSafariViewController(url: url!, configuration: config)
            }
            present(vc, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if !(tableView is MarketNewsTableView) {
            Dataholder.selectedCompany = searchResults[indexPath.row]
        }
        return indexPath
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let button = sender as? UIButton {
            let company = self.buttonCompanyDict[button]!
            Dataholder.selectedCompany = company
        }

    }
    

}
