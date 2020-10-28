//
//  WatchlistTVC.swift
//  stonks
//
//  Created by Samuel Hobel on 9/28/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import UIKit
import AuthenticationServices

class WatchlistVC: UIViewController, Updateable {
    
    @IBOutlet weak var addTickerButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    private var watchlistUpdater: WatchlistUpdater?
    private var finvizAPI:FinvizAPI!
    
    private var watchlistManager:WatchlistManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.watchlistManager = Dataholder.watchlistManager
        self.loadWatchlist()
        
        finvizAPI = FinvizAPI()
//        finvizAPI.getData(forTickers: , completionHandler: handleFinvizResponse)
        
        self.addTickerButton.layer.shadowColor = UIColor.black.cgColor
        self.addTickerButton.layer.shadowOpacity = 0.7
        self.addTickerButton.layer.shadowOffset = .zero
        self.addTickerButton.layer.shadowRadius = 3
        
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
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //updateFinvizData()
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    }
    
    private func loadWatchlist(){
        NetworkManager.getMyRestApi().getWatchlistForCurrentUser() {
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
    
    private func updateFinvizData(){
        var tickers:[String] = []
        for c in watchlistManager.getWatchlist(){
            if c.analystsRating == nil && c.getIsCompany(){
                tickers.append(c.symbol)
            }
        }
    }
    
    public func updateFromScheduledTask(_ data:Any?){
        let watchlist = self.watchlistManager.getWatchlist()
        if watchlist.count > 0 && watchlist[0].quote != nil {
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
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
     
    @objc func handleRefresh() {
        self.loadWatchlist()
    }
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
