//
//  CompanySearchTVC.swift
//  stonks
//
//  Created by Samuel Hobel on 9/30/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import UIKit

extension CompanySearchTVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterList(searchText: searchText)
        self.tableView.reloadData()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.dismiss(animated: true, completion: nil)
    }
}

class CompanySearchTVC: UITableViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    var searchResults:[Company] = []
    var activityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.autocapitalizationType = .none
        searchBar.delegate = self
        activityIndicatorView = UIActivityIndicatorView(style: .large)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Dataholder.allTickers.isEmpty {
            //StockAPIManager.shared.getStockDataAPI().listCompanies(completionHandler: handleListCompanies)
            
            //tableView.backgroundView = activityIndicatorView
            //activityIndicatorView.startAnimating()
        }
    }
    
    public func handleListCompanies(){
        DispatchQueue.main.async {
            if let searchText = self.searchBar.text {
                self.filterList(searchText: searchText)
                self.tableView.reloadData()
            }
            self.activityIndicatorView.stopAnimating()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "companySearchCell", for: indexPath)

        let company = searchResults[indexPath.row]
        cell.textLabel?.text = searchResults[indexPath.row].symbol
        cell.detailTextLabel?.text = company.fullName

        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Dataholder.watchlistManager.addCompany(company: searchResults[indexPath.row])
        self.dismiss(animated: true, completion: nil)
    }

    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    */

}
