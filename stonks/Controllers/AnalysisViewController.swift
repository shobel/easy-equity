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
        filterList(searchText: searchText)
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
    
    private var scores:[SimpleScore] = []
    private var scoresOriginal:[SimpleScore] = []
    
    private var colorMap:[String:UIColor] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureButton.layer.cornerRadius = 15
        configureButton.layer.borderColor = UIColor.darkGray.cgColor
        configureButton.layer.borderWidth = CGFloat(1)
        
        self.companyScoresTable.delegate = self
        self.companyScoresTable.dataSource = self
        self.searchbar.delegate = self
        
        NetworkManager.getMyRestApi().getScoresWithUserSettingsApplied { (scores) in
            self.scores = scores.sorted(by: { (a, b) -> Bool in
                return b.rank ?? 0 > a.rank ?? 0
            })
            for score in self.scores {
                if self.colorMap[score.industry ?? ""] == nil {
                    self.colorMap[score.industry ?? ""] = self.generateRandomColor()
                }
            }
            self.scoresOriginal = self.scores
            DispatchQueue.main.async {
                self.companyScoresTable.reloadData()
            }
        }
    }
    
    private func filterList(searchText: String){
        if searchText == "" {
            self.scores = self.scoresOriginal
        } else {
            self.scores = self.scoresOriginal.filter {
                ($0.symbol ?? "").lowercased().starts(with: searchText.lowercased()) ||
                ($0.companyName ?? "").lowercased().starts(with: searchText.lowercased()) ||
                ($0.industry ?? "").lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    private func generateRandomColor() -> UIColor {
        let max = 175
        var red = CGFloat(Int.random(in: 10..<max))
        var blue = CGFloat(Int.random(in: 10..<max))
        var green = CGFloat(Int.random(in: 10..<max))
        let rand = Int.random(in: 1..<10)
        if rand < 4 {
            red = CGFloat(max)
        } else if rand < 7 {
            green = CGFloat(max)
        } else {
            blue = CGFloat(max)
        }
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1.0)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.scores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "scoreTVC", for: indexPath) as! CompanyScoreTableViewCell
        let score = self.scores[indexPath.row]
        cell.symbol.text = score.symbol ?? "-"
        cell.companyName.text = score.companyName ?? "-"
        cell.industry.text = score.industry ?? "-"
        cell.rank.text = String(score.rank ?? 0)
        cell.industryRank.text = String(score.industryRank ?? 0)
        cell.setData(industryColor: self.colorMap[score.industry ?? ""] ?? UIColor.gray, rank: score.rank ?? 0, industryRank: score.industryRank ?? 0, industryTotal: score.industryTotal ?? 1, percentile: score.percentile ?? 0.0)
        cell.backgroundColor = UIColor.clear
        return cell
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
