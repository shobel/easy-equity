//
//  TweetViewController.swift
//  stonks
//
//  Created by Samuel Hobel on 4/4/22.
//  Copyright © 2022 Samuel Hobel. All rights reserved.
//

import UIKit

class TweetViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tit: UILabel!
    
    var tweets:[Tweet] = []
    var username:String = "User"
    var symbol:String = "Symbol"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if self.tit != nil {
            if self.symbol == "RECENT" {
                self.tit.text = self.username + "'s Recent Tweets"
            } else {
                self.tit.text = self.username + "'s Tweets About " + self.symbol
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "tweetCell") as! TweetTableViewCell
        let tweet = self.tweets[indexPath.row]
        cell.createdAt.text = tweet.createdAt
        cell.cashtags.text = tweet.cashtags?.joined(separator: ",")
        cell.tweet.text = tweet.text ?? ""
        return cell
    }
    
    public func setData(_ username:String, symbol:String){
        self.username = username
        self.symbol = symbol
        NetworkManager.getMyRestApi().getTweetsForTwitterAccountAndSymbol(username, symbol: symbol) { tweets in
            self.tweets = tweets.reversed()
            DispatchQueue.main.async {
                if self.tableView != nil {
                    self.tableView.reloadData()
                }
            }
        }
        DispatchQueue.main.async {
            if self.tit != nil {
                self.tit.text = self.username + "'s Tweets About " + self.symbol
            }
        }
    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
