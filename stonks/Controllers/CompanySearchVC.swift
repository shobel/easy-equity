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
        currentTop10List.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "top10cell", for: indexPath) as! Top10CollectionViewCell
        let item = currentTop10List[indexPath.row]
        cell.symbolLabel.text = item.symbol
        cell.changePercentLabel.setValue(value: item.changePercent, isPercent: true)
        cell.latestPriceLabel.text = String("$\(item.latestPrice)")
        cell.latestPriceLabel.textColor = cell.changePercentLabel.getColor(value: item.changePercent)
        self.buttonCompanyDict[cell.segueButton] = Company(symbol: item.symbol, fullName: item.companyName)
        return cell;
    }
    
}

class CompanySearchVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var marketNewsTableView: MarketNewsTableView!
    
    @IBOutlet weak var marketView: UIView!
    @IBOutlet weak var top10CollectionView: UICollectionView!
    @IBOutlet weak var top10Title: UILabel!
    
    public var searchResults:[Company] = []
    public var activityIndicatorView: UIActivityIndicatorView!
    
    public var top10s:Top10s?
    public var currentTop10List:[SimpleQuote] = []
    public var marketNews:[News] = []
    private var buttonCompanyDict:[UIButton:Company] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        top10CollectionView.delegate = self
        top10CollectionView.dataSource = self
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
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NetworkManager.getMyRestApi().getTop10s(completionHandler: handleTop10s)
        NetworkManager.getMyRestApi().getMarketNews(completionHandler: handleMarketNews)
        if Dataholder.allTickers.isEmpty {
            self.loadingStarted()
            NetworkManager.getMyRestApi().listCompanies(completionHandler: handleListCompanies)
        }
    }
    
    @IBAction func nextTop10List(_ sender: Any) {
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
    
    private func handleListCompanies(_ companies:[Company]) {
        Dataholder.allTickers = companies
        self.loadingFinished()
    }
    
    private func handleMarketNews(_ news: [News]){
        self.marketNews = news
        DispatchQueue.main.async {
            self.marketNewsTableView.reloadData()
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
        DispatchQueue.main.async {
            self.currentTop10List = self.top10s?.gainers ?? []
            self.top10CollectionView.reloadData()
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
