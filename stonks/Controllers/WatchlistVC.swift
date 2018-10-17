//
//  WatchlistTVC.swift
//  stonks
//
//  Created by Samuel Hobel on 9/28/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import UIKit

class WatchlistVC: UIViewController {
    
    @IBOutlet weak var addTickerButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    private var watchlistUpdater: WatchlistUpdater?
    private var finvizAPI:FinvizAPI!
    
    private var watchlistManager:WatchlistManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        watchlistManager = Dataholder.watchlistManager
        
        finvizAPI = FinvizAPI()
        finvizAPI.getData(forTickers: watchlistManager.getTickers(companiesOnly: true), completionHandler: handleFinvizResponse)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorInset = UIEdgeInsets.zero
        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl!.addTarget(self, action: #selector(handleRefresh), for: UIControl.Event.valueChanged)
    }
    
    /* helps the rating score colors stick better when moving from other views to this one */
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateFinvizData()
        self.tableView.reloadData()
        if !watchlistManager.getWatchlist().isEmpty {
            watchlistUpdater = WatchlistUpdater(caller: self)
            watchlistUpdater!.startTask()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        watchlistUpdater?.stopTask()
    }
    
    private func updateFinvizData(){
        var tickers:[String] = []
        for c in watchlistManager.getWatchlist(){
            if c.analystsRating == nil && c.isCompany{
                tickers.append(c.ticker)
            }
        }
        if !tickers.isEmpty {
            finvizAPI.getData(forTickers: tickers, completionHandler: handleFinvizResponse)
        }
    }
    
    private func handleFinvizResponse(data: [String:[String:Any?]]){
        for c in watchlistManager.getWatchlist(){
            if let ticker = data.keys.first {
                if ticker == c.ticker {
                    c.analystsRating = data[ticker]!["ratings"] as? AnalystsRating
                    
                    let earningsDateString = data[ticker]!["Earnings"] as? String
                    let erArray = earningsDateString?.components(separatedBy: .whitespaces)
                    let time = erArray![2]
                    
                    let today = Date()
                    let calendar = Calendar.current
                    let year = calendar.component(.year, from: today)
                    
                    let earningsDate = erArray![0] + " " + erArray![1] + " " + String(year)
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MMM dd yyyy"
                    dateFormatter.timeZone = TimeZone(abbreviation: "EST")
                    guard let date = dateFormatter.date(from: earningsDate) else {
                        fatalError()
                    }
                    c.earningsDate = date
                    break
                }
            }
        }
        update()
    }
    
    public func update(){
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    
    /*
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     }
     */
    
    @objc func handleRefresh() {
        self.tableView.reloadData()
        self.tableView.refreshControl!.endRefreshing()
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
            Dataholder.watchlistManager.removeCompany(index: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        watchlistManager.selectedCompany = watchlistManager.getWatchlist()[indexPath.row]
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