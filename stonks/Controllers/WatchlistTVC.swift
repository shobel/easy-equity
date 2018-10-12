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
    
    var refreshLoadingView : UIView!
    var goatView : UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setupRefreshControl()
    }
    
    func setupRefreshControl() {
        // Programmatically inserting a UIRefreshControl
        self.refreshControl = UIRefreshControl()
        
        // Setup the loading view, which will hold the moving graphics
        self.refreshLoadingView = UIView(frame: self.refreshControl!.bounds)
        self.refreshLoadingView.backgroundColor = UIColor.red
    
        // Create the graphic image views
        self.goatView = UIImageView(image: UIImage(named: "goat-loader.gif"))
        
        // Add the graphics to the loading view
        self.refreshLoadingView.addSubview(self.goatView)
        
        // Clip so the graphics don't stick out
        self.refreshLoadingView.clipsToBounds = true;
        
        // Hide the original spinner icon
        self.refreshControl!.tintColor = UIColor.clear
        
        // Add the loading and colors views to our refresh control
        self.refreshControl!.addSubview(self.refreshLoadingView)
        
        // When activated, invoke our refresh function
        self.refreshControl!.addTarget(self, action: #selector(handleRefresh), for: UIControl.Event.valueChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
        if !Dataholder.watchList.isEmpty {
            watchlistUpdater = WatchlistUpdater(caller: self)
            watchlistUpdater!.startTask()
        }
    }

    public func update(){
        DispatchQueue.main.async {
            self.tableView.reloadData()
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
        cell.displayData(company: company)
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
    
    @objc func handleRefresh() {
        self.tableView.reloadData()
        self.refreshControl!.endRefreshing()
    }

}
