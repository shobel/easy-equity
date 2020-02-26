//
//  NewsTableViewController.swift
//  stonks
//
//  Created by Samuel Hobel on 2/16/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import UIKit
import WebKit

class NewsTableViewController: UITableViewController, StatsVC, WKUIDelegate, WKNavigationDelegate {

    private var company:Company!
    private var isLoaded:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.isScrollEnabled = false
        self.isLoaded = true
        self.company = Dataholder.watchlistManager.selectedCompany!
        updateData()
    }
    
    func updateData() {
        self.company = Dataholder.watchlistManager.selectedCompany!
    }
    
    func getContentHeight() -> CGFloat {
        if isLoaded {
            return CGFloat((self.company.news?.count ?? 0) * 90)
        }
        return 0.0
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.company.news?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newscell") as! NewsTableViewCell
        let news:News = (self.company.news?[indexPath.row])!
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
    
    //In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! NewsTableViewCell
        let dest = segue.destination as! NewsWebViewController
        if let url = URL(string: cell.url!) {
            DispatchQueue.main.async {
                if let wv = dest.webView {
                    wv.allowsBackForwardNavigationGestures = true
                    wv.load(URLRequest(url: url))
                }
            }
        }
        
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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
