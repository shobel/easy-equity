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

class WatchlistVC: UIViewController, Updateable, ShadowButtonDelegate {
    
    @IBOutlet weak var creditBalanceView: ShadowButtonView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerBgView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var watchlistUpdater: WatchlistUpdater?
    private var watchlistManager:WatchlistManager!
    private var firstUpdateDone:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.activityIndicator.startAnimating()
        self.activityIndicator.isHidden = false
        
        Dataholder.subscribeForCreditBalanceUpdates(self)
        self.creditBalanceView.delegate = self
        self.creditBalanceView.bgColor = Constants.orange
        self.creditBalanceView.shadColor = UIColor(red: 100.0/255.0, green: 60.0/255.0, blue: 25.0/255.0, alpha: 1.0).cgColor
        self.headerBgView.addGradientBackground()
        
        self.watchlistManager = Dataholder.watchlistManager
        self.loadWatchlist()
        
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
        
    }
    
    /* helps the rating score colors stick better when moving from other views to this one */
    override func viewWillAppear(_ animated: Bool) {
        self.watchlistUpdated()
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //updateFinvizData()
        self.tableView.reloadData()
        self.creditBalanceView.credits.text = String("\(Dataholder.getCreditBalance())")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    }
    
    private func loadWatchlist(){
        NetworkManager.getMyRestApi().getWatchlistForCurrentUser() {
            
            NetworkManager.getMyRestApi().getScoresForSymbolsWithUserSettingsApplied(symbols: self.watchlistManager.getWatchlistSymbols()) { scores in
                for score in scores {
                    for company in self.watchlistManager.getWatchlist() {
                        if score.symbol == company.symbol {
                            company.simpleScore = score
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
            DispatchQueue.main.async {
                if !self.watchlistManager.getWatchlist().isEmpty {
                    let marketOpen = self.watchlistManager.getWatchlist().first?.quote?.isUSMarketOpen
                    var timeInterval = 5.0 //5.0
                    if let mo = marketOpen {
                        if !mo {
                            timeInterval = 60.0 //60.0
                        }
                    }
                    if self.watchlistUpdater == nil {
                        self.watchlistUpdater = WatchlistUpdater(caller: self, timeInterval: timeInterval)
                        self.watchlistUpdater!.startTask()
                    } else {
                        self.watchlistUpdater?.changeTimeInterval(newTimeInterval: timeInterval)
                    }
                }
                self.tableView.refreshControl!.endRefreshing()
            }
        }
    }
    
    public func updateFromScheduledTask(_ data:Any?){
        if !self.firstUpdateDone {
            self.firstUpdateDone = true
            DispatchQueue.main.async {
                self.activityIndicator.isHidden = true
            }
        }
        let watchlist = self.watchlistManager.getWatchlist()
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
                if watchlist[0].quote!.isUSMarketOpen {
                    self.watchlistUpdater?.changeTimeInterval(newTimeInterval: 5.0)
                    self.watchlistUpdater?.hibernating = false
                } else {
                    self.watchlistUpdater?.changeTimeInterval(newTimeInterval: 60.0) //60.0
                    if GeneralUtility.isPremarket() || GeneralUtility.isAftermarket(){
                        self.watchlistUpdater?.hibernating = false
                    } else {
                        self.watchlistUpdater?.hibernating = true
                    }
                }
            }
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
     
    @objc func handleRefresh() {
        self.loadWatchlist()
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
    
    public func watchlistUpdated() {
        NetworkManager.getMyRestApi().getScoresForSymbolsWithUserSettingsApplied(symbols: self.watchlistManager.getWatchlistSymbols()) { scores in
            for score in scores {
                for company in self.watchlistManager.getWatchlist() {
                    if score.symbol == company.symbol {
                        company.simpleScore = score
                    }
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        if let wu = self.watchlistUpdater {
            wu.hibernating = false
            wu.update()
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
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
        return watchlistManager.getWatchlist().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "watchListCell", for: indexPath) as! WatchlistTVCell
        let company = watchlistManager.getWatchlist()[indexPath.row]
        cell.displayData(company: company)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            Dataholder.watchlistManager.removeCompanyByIndex(index: indexPath.row){
                DispatchQueue.main.async {
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Dataholder.selectedCompany = watchlistManager.getWatchlist()[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        Dataholder.selectedCompany = watchlistManager.getWatchlist()[indexPath.row]
        return indexPath
    }
    
    /*
    func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
}
