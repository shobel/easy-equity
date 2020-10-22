//
//  AnalysisViewController.swift
//  stonks
//
//  Created by Samuel Hobel on 10/21/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import UIKit

extension AnalysisViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //filterList(searchText: searchText)
        self.companyScoresTable.reloadData()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.dismiss(animated: true, completion: nil)
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchbar.resignFirstResponder()
    }
}

class AnalysisViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var configureButton: UIButton!
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var companyScoresTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureButton.layer.cornerRadius = 15
        configureButton.layer.borderColor = UIColor.darkGray.cgColor
        configureButton.layer.borderWidth = CGFloat(1)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
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
