//
//  TwitterAccountsViewController.swift
//  stonks
//
//  Created by Samuel Hobel on 4/3/22.
//  Copyright © 2022 Samuel Hobel. All rights reserved.
//

import UIKit
import FCAlertView

class TwitterAccountsViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var helpText: UILabel!
    @IBOutlet weak var twitterAccountTableView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    
    //twitter account search results
    @IBOutlet weak var foundContainer: UIView!
    @IBOutlet weak var foundBox: ShadowView!
    @IBOutlet weak var foundUrl: UIImageView!
    @IBOutlet weak var foundName: UILabel!
    @IBOutlet weak var foundUsername: UILabel!
    
    private var twitterAccounts:[(account: TwitterAccount, cashtags:[Cashtag])] = [] {
        didSet {
            DispatchQueue.main.async {
                self.emptyView.isHidden = self.twitterAccounts.count > 0 ? true : false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchbar.delegate = self
        self.twitterAccountTableView.delegate = self
        self.twitterAccountTableView.dataSource = self
        self.twitterAccountTableView.refreshControl = UIRefreshControl()
        self.twitterAccountTableView.refreshControl?.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)

        self.twitterAccountTableView.refreshControl?.beginRefreshing()
        NetworkManager.getMyRestApi().getTwitterAccounts(completionHandler: handleGetAccounts)
    }
    
    @objc private func refresh(_ sender: Any){
        self.twitterAccountTableView.refreshControl?.endRefreshing()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.twitterAccountTableView.refreshControl?.beginRefreshing()
            self.twitterAccountTableView.setContentOffset(CGPoint(x: 0, y: -(self.twitterAccountTableView.refreshControl?.frame.size.height)!), animated: true)
            if let username = self.twitterAccounts[indexPath.row].account.username {
                NetworkManager.getMyRestApi().removeTwitterAccount(username) {
                    NetworkManager.getMyRestApi().getTwitterAccounts(completionHandler: self.handleGetAccounts)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        print()
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.twitterAccounts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.twitterAccountTableView.dequeueReusableCell(withIdentifier: "twitterAccountCell") as! TwitterAccountTableViewCell
        let twitterAccount = self.twitterAccounts[indexPath.row]
        if let url = URL(string: twitterAccount.account.profile_image_url ?? "") {
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    cell.imageUrl.image = image
                }
            }
        }
        let ta = twitterAccount.account
        cell.username.text = "@" + (ta.username ?? "")
        cell.name.text = ta.name ?? ""
        cell.followers.text = NumberFormatter.formatNumber(num: Double(ta.followers_count ?? 0))
        cell.following.text = NumberFormatter.formatNumber(num: Double(ta.following_count ?? 0))
        cell.tweetCount.text = NumberFormatter.formatNumber(num: Double(ta.tweet_count ?? 0))
        cell.desc.text = ta.description ?? ""
        cell.setData(twitterAccount.cashtags)
        cell.parentVC = self
        return cell
    }
    
    func handleGetAccounts(_ accounts: [(account: TwitterAccount, cashtags:[Cashtag])]) {
        self.twitterAccounts = accounts
        self.twitterAccounts.sort { a, b in
            a.account.name ?? "" < b.account.name ?? ""
        }
        DispatchQueue.main.async {
            self.twitterAccountTableView.reloadData()
            self.twitterAccountTableView.refreshControl?.endRefreshing()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchbar.endEditing(true)
        if let searchterm = searchBar.text {
            DispatchQueue.main.async {
                self.twitterAccountTableView.refreshControl?.beginRefreshing()
                self.twitterAccountTableView.setContentOffset(CGPoint(x: 0, y: -(self.twitterAccountTableView.refreshControl?.frame.size.height)!), animated: true)
            }
            NetworkManager.getMyRestApi().getTwitterAccount(searchterm) { twitterAccount, error in
                if let error = error {
                    DispatchQueue.main.async {
                        self.twitterAccountTableView.refreshControl?.endRefreshing()
                    }
                    self.showErrorAlert(error)
                } else if let ta = twitterAccount {
                    DispatchQueue.main.async {
                        self.foundUsername.text = "@" + (ta.username ?? "")
                        self.foundName.text = ta.name
                        if let url = URL(string: ta.profile_image_url ?? "") {
                            if let data = try? Data(contentsOf: url) {
                                if let image = UIImage(data: data) {
                                    self.foundUrl.image = image
                                }
                            }
                        }
                        self.foundContainer.isHidden = false
                        self.twitterAccountTableView.refreshControl?.endRefreshing()
                    }
                }
            }
        }
    }
    
    func handleTwitterAccount(_ twitterAccount:TwitterAccount?, cashtags:[Cashtag]) {
        if twitterAccount != nil {
            self.twitterAccounts.append((account: twitterAccount!, cashtags: cashtags))
            self.twitterAccounts.sort { a, b in
                a.account.name ?? "" < b.account.name ?? ""
            }
            DispatchQueue.main.async {
                self.twitterAccountTableView.reloadData()
                self.twitterAccountTableView.refreshControl?.endRefreshing()
            }
        }
    }
    
    public func setUsernameAndselectedCashtag(_ username:String, cashtag:String){
        let vc:TweetViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tweetVC") as! TweetViewController
        vc.setData(username, symbol: cashtag)
        
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func addUserTapped(_ sender: Any) {
        var username:String = self.foundUsername.text!
        if self.foundUsername.text!.contains("@"){
            username = String(self.foundUsername.text!.dropFirst())
        }
        DispatchQueue.main.async {
            self.twitterAccountTableView.refreshControl?.beginRefreshing()
            self.twitterAccountTableView.setContentOffset(CGPoint(x: 0, y: -(self.twitterAccountTableView.refreshControl?.frame.size.height)!), animated: true)
        }
        NetworkManager.getMyRestApi().addTwitterAccount(username, completionHandler: self.handleTwitterAccount)
        self.foundContainer.isHidden = true
    }
    @IBAction func cancelTapped(_ sender: Any) {
        self.foundContainer.isHidden = true
    }

    func showErrorAlert(_ error: String?){
        DispatchQueue.main.async {
            let message = error ?? ""
            let alert = FCAlertView()
            alert.doneActionBlock {
                //
            }
            alert.colorScheme = Constants.darkPink
            alert.dismissOnOutsideTouch = true
            alert.detachButtons = true
            alert.showAlert(inView: self,
                            withTitle: "Error",
                            withSubtitle: message,
                            withCustomImage: UIImage(named: "twitter.png"),
                            withDoneButtonTitle: "Ok",
                            andButtons: [])
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
     */
    

}
