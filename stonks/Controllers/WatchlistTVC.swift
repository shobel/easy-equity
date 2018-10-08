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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
        if !Dataholder.watchList.isEmpty {
            watchlistUpdater = WatchlistUpdater()
            watchlistUpdater!.startTask()
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Dataholder.watchList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "watchListCell", for: indexPath) as! WatchlistTVCell

        let company = Dataholder.watchList[indexPath.row]
        cell.ticker.text = company.ticker
        cell.fullName.text = company.fullName
        cell.currentPrice.text = String(format: "%.2f", Double.random(in: 1 ..< 2000)) //"\(company.currentPrice)"
        cell.priceChange.text = String(format: "%.2f", Double.random(in: 1 ..< 20)) //"\(company.priceChange)"
        cell.percentChange.text = String(format: "%.2f", Double.random(in: 1 ..< 20)) + "%" //"\(company.percentChange)"
        cell.daysToER.text = "\(Int.random(in: 1 ..< 30))d"
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            Dataholder.removeFromWatchList(index: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        watchlistUpdater?.stopTask()
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
