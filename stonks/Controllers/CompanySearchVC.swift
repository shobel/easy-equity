//
//  CompanySearchTVC.swift
//  stonks
//
//  Created by Samuel Hobel on 9/30/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import UIKit

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
        10//top10s.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "top10cell", for: indexPath) as! Top10CollectionViewCell
        return cell;
    }
    
}

class CompanySearchVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var marketView: UIView!
    @IBOutlet weak var top10CollectionView: UICollectionView!
    
    public var searchResults:[Company] = []
    public var activityIndicatorView: UIActivityIndicatorView!
    public var top10s:[Top10List] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        top10CollectionView.delegate = self
        top10CollectionView.dataSource = self
        tableView.isHidden = true
        marketView.isHidden = false
        
        tableView.tableFooterView = UIView(frame: .zero)
        searchBar.autocapitalizationType = .none
        searchBar.delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
        activityIndicatorView = UIActivityIndicatorView(style: .large)
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.center = self.view.center
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Dataholder.allTickers.isEmpty {
            self.loadingStarted()
            NetworkManager.getMyRestApi().listCompanies(completionHandler: self.loadingFinished)
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
        return searchResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Dataholder.watchlistManager.selectedCompany = searchResults[indexPath.row]
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        Dataholder.watchlistManager.selectedCompany = searchResults[indexPath.row]
        return indexPath
    }
    
    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    */

}
