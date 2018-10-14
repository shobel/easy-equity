//
//  WatchlistTVC.swift
//  stonks
//
//  Created by Samuel Hobel on 9/28/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import UIKit

class WatchlistTVC: UITableViewController {

    @IBOutlet weak var addTickerButton: UIButton!
    private var watchlistUpdater: WatchlistUpdater?
    private var analystRatingAPI:FinvizAPI!
    
    private var watchlistManager:WatchlistManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        watchlistManager = Dataholder.watchlistManager
        
        analystRatingAPI = FinvizAPI()
        analystRatingAPI.getAnalystsRatings(forTickers: watchlistManager.getTickers(), completionHandler: handleAnalystsRatings)
        
        tableView.separatorInset = UIEdgeInsets.zero
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: #selector(handleRefresh), for: UIControl.Event.valueChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateEarningsAndRatings()
        self.tableView.reloadData()
        if !watchlistManager.getWatchlist().isEmpty {
            watchlistUpdater = WatchlistUpdater(caller: self)
            watchlistUpdater!.startTask()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        watchlistUpdater?.stopTask()
    }
    
    private func updateEarningsAndRatings(){

    }
    
    private func handleAnalystsRatings(ratings: [String:AnalystsRating]){
        for rating in ratings {
            
        }
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
        self.refreshControl!.endRefreshing()
    }
}

/* TableView functions */
extension WatchlistTVC {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return watchlistManager.getWatchlist().count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "watchListCell", for: indexPath) as! WatchlistTVCell
        
        let company = watchlistManager.getWatchlist()[indexPath.row]
        cell.displayData(company: company)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            Dataholder.watchlistManager.removeCompany(index: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
}
