//
//  TopAnalystsViewController.swift
//  stonks
//
//  Created by Samuel Hobel on 2/9/22.
//  Copyright © 2022 Samuel Hobel. All rights reserved.
//

import UIKit
import XLActionController

struct StockExtraAnalystData {
    var freshness:Double
    var latestPrice:Double
    var totalScore:Double
    
}

class TopAnalystsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var searchbar: UISearchBar!
    
    private var topAnalystDataAll:[PriceTargetTopAnalysts] = []
    private var topAnalystDataToShow:[PriceTargetTopAnalysts] = []
    private var stockExtraData:[String:StockExtraAnalystData] = [:]
    private var rankingDict:[String: Int] = [:]
    private var analystDataSortedByScore:[StockExtraAnalystData] = []
    private var fidelityScoreDic:[String:FidelityScore] = [:]
    
    private var selectedSymbol:PriceTargetTopAnalysts?
    
    private var minMaxes:[String:(mini: Double, maxi: Double)] = [
        "numAnalysts": (mini: Double(Int.max), maxi: Double(Int.min)),
        "avgRank": (mini: Double(Int.max), maxi: Double(Int.min)),
        "priceTarget": (mini: Double(Int.max), maxi: Double(Int.min)),
        "freshness": (mini: Double(Int.max), maxi: Double(Int.min)),
        "numRatings": (mini: Double(Int.max), maxi: Double(Int.min))
    ]


    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.searchbar.delegate = self
        DispatchQueue.main.async {
            self.loader.isHidden = false
        }
        NetworkManager.getMyRestApi().getTiprankSymbols(nil, completionHandler: handleTopAnalysts)
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    func clearData(){
        self.topAnalystDataAll = []
        self.topAnalystDataToShow = []
        self.stockExtraData = [:]
        self.rankingDict = [:]
        self.analystDataSortedByScore = []
        self.fidelityScoreDic = [:]
        self.minMaxes = [
            "numAnalysts": (mini: Double(Int.max), maxi: Double(Int.min)),
            "avgRank": (mini: Double(Int.max), maxi: Double(Int.min)),
            "priceTarget": (mini: Double(Int.max), maxi: Double(Int.min)),
            "freshness": (mini: Double(Int.max), maxi: Double(Int.min)),
            "numRatings": (mini: Double(Int.max), maxi: Double(Int.min))
        ]
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.topAnalystDataToShow = []
        let searchText = searchBar.text ?? ""
        if searchText.isEmpty {
            self.topAnalystDataToShow = self.topAnalystDataAll
        } else {
            for var tad in self.topAnalystDataAll {
                if tad.symbol != nil && tad.symbol!.uppercased().starts(with: searchText.uppercased()) {
                    self.topAnalystDataToShow.append(tad)
                }
            }
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchbar.resignFirstResponder()
    }
    
    @IBAction func sortButtonPressed(_ sender: Any) {
        let actionController = SkypeActionController() //not really for skype
        actionController.addAction(Action("Overall Score", style: .default, handler: { action in
            self.topAnalystDataToShow.sort(by: { (x1, x2) -> Bool in
                return self.stockExtraData[x1.symbol!]!.totalScore >
                self.stockExtraData[x2.symbol!]!.totalScore
            })
            self.tableView.reloadData()
        }))
        actionController.addAction(Action("Number of Analysts", style: .default, handler: { action in
            self.tableView.reloadData()
            self.topAnalystDataToShow.sort(by: { (x1, x2) -> Bool in
                return x1.numAnalysts ?? 0 > x2.numAnalysts ?? 0
            })
        }))
        actionController.addAction(Action("Upside", style: .default, handler: { action in
            self.topAnalystDataToShow.sort(by: { (x1, x2) -> Bool in
                return x1.upsidePercent ?? 0.0 > x2.upsidePercent ?? 0.0
                
            })
            self.tableView.reloadData()
        }))
        actionController.addAction(Action("Newest Ratings", style: .default, handler: { action in
            self.topAnalystDataToShow.sort(by: { (x1, x2) -> Bool in
                return self.stockExtraData[x1.symbol!]!.freshness <
                self.stockExtraData[x2.symbol!]!.freshness
                
            })
            self.tableView.reloadData()
        }))
        present(actionController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        self.selectedSymbol = self.topAnalystDataToShow[indexPath.row]
        return indexPath
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.topAnalystDataToShow.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "topAnalystsCell", for: indexPath) as! TopAnalystsTableViewCell
        let item = self.topAnalystDataToShow[indexPath.row]
        if item.symbol != nil {
            let latestQuote = self.stockExtraData[item.symbol!]!.latestPrice
            cell.symbol.text = item.symbol ?? "n/a"
            cell.numAnalysts.text = String("\(item.numAnalysts ?? 0)") + " analysts"
            cell.avgRank.text = String(format: "%.1f", item.avgAnalystRank ?? 0.0) + " avg rank"
            cell.successRate.text = String(format: "%.1f%%", (item.avgAnalystSuccessRate ?? 0.0)*100.0)
            cell.successRate.text! += String(format: " (%.1f%%)", (item.avgAnalystSuccessRateThisStock ?? 0.0)*100.0)
            cell.successRateProgress.setProgressNoLabel((item.avgAnalystSuccessRate ?? 0.0))
            var ptText = String(format: "%.0f", item.avgPriceTarget ?? 0.0)
            if let upsidePercent = item.upsidePercent {
                if (upsidePercent > 0) {
                    ptText = ptText + String(format: " (+%.0f%%)", upsidePercent)
                } else {
                    ptText = ptText + String(format: " (%.0f%%)", upsidePercent)
                }
            }
            ptText = ptText + " PT"
            cell.avgPriceTarget.text = ptText
            var lowPtText = String(format: "%.0f", item.lowPriceTarget ?? 0.0)
            var highPtText = String(format: "%.0f", item.highPriceTarget ?? 0.0)
            if item.lowPriceTarget != nil && item.highPriceTarget != nil {
                cell.latestPrice.text = String(format: "%.2f", latestQuote)
                let pctLow = ((item.lowPriceTarget! - latestQuote) / latestQuote)*100.0
                let pctHigh = ((item.highPriceTarget! - latestQuote) / latestQuote)*100.0
                if pctLow > 0 {
                    lowPtText += String(format: " (+%.0f%%)", pctLow)
                } else {
                    lowPtText += String(format: " (%.0f%%)", pctLow)
                }
                if pctHigh > 0 {
                    highPtText += String(format: " (+%.0f%%)", pctHigh)
                } else {
                    highPtText += String(format: " (%.0f%%)", pctHigh)
                }
            }
            cell.lowPriceTarget.text = lowPtText
            cell.highPriceTarget.text = highPtText
            cell.numRatings.text = String("\((item.numRatings ?? 0)/(item.numAnalysts ?? 0))") + " ratings/analyst"
            let freshness:Double = self.stockExtraData[item.symbol!]!.freshness
            cell.freshness.text = String(format: "%.1f days ago", freshness)
            
            let fscore:FidelityScore? = self.fidelityScoreDic[item.symbol ?? ""]
            if fscore != nil {
                let value = fscore!.score
                cell.fidelityScoreVal.text = (value ?? "0")
                cell.fidelityScore.tintColor = self.getScoreTextColor((Double(value ?? "0.0") ?? 0.0) / 10.0)
                cell.fidelityScoreVal.isHidden = false
                cell.fidelityScore.isHidden = false
            } else {
                cell.fidelityScoreVal.isHidden = true
                cell.fidelityScore.isHidden = true
            }
            cell.totalScore.text = String(0)
            if self.stockExtraData.keys.contains(item.symbol!) {
                cell.totalScore.text = String(format: "%.1f pts", self.stockExtraData[item.symbol!]!.totalScore)
                cell.rank.text = "Rank " + String((self.topAnalystDataAll.firstIndex(where: {
                    x -> Bool in
                    return x.symbol?.uppercased() == item.symbol!.uppercased()
                }) ?? 0) + 1)
            }
            
            var score = Double(item.numAnalysts!)
            if  self.minMaxes["numAnalysts"] != nil {
                let min = self.minMaxes["numAnalysts"]!.mini
                let max = self.minMaxes["numAnalysts"]!.maxi
                cell.setIconColor(TopAnalystsTableViewCell.IconName.numAnalysts, percent: (score - min) / (max - min))
            }
            score = Double(item.upsidePercent!)
            if  self.minMaxes["priceTarget"] != nil {
                let min = self.minMaxes["priceTarget"]!.mini
                let max = self.minMaxes["priceTarget"]!.maxi
                cell.setIconColor(TopAnalystsTableViewCell.IconName.priceTarget, percent: (score - min) / (max - min))
            }
            score = Double(item.avgAnalystRank!)
            if  self.minMaxes["avgRank"] != nil {
                let min = self.minMaxes["avgRank"]!.mini
                let max = self.minMaxes["avgRank"]!.maxi
                cell.setIconColor(TopAnalystsTableViewCell.IconName.avgRank, percent: 1.0 - ((score - min) / (max - min)))
            }
            score = Double(freshness)
            if  self.minMaxes["freshness"] != nil {
                let min = self.minMaxes["freshness"]!.mini
                let max = self.minMaxes["freshness"]!.maxi
                cell.setIconColor(TopAnalystsTableViewCell.IconName.freshness, percent: 1.0 - ((score - min) / (max - min)))
            }
            score = Double(item.numRatings!) / Double(item.numAnalysts!)
            if  self.minMaxes["numRatings"] != nil {
                let min = self.minMaxes["numRatings"]!.mini
                let max = self.minMaxes["numRatings"]!.maxi
                cell.setIconColor(TopAnalystsTableViewCell.IconName.numRatings, percent: (score - min) / (max - min))
            }
        }
        
        return cell
    }

    private func handleTopAnalysts(_ topAnalystSymbols:[PriceTargetTopAnalysts]) {
        self.topAnalystDataAll = topAnalystSymbols
        for tad in self.topAnalystDataAll {
            self.stockExtraData[tad.symbol!] = StockExtraAnalystData(freshness: 0.0, latestPrice: 0.0, totalScore: 0.0)
            var totalDays:Double = 0.0
            var avgFreshness:Double = -1.0
            if (tad.expertRatings != nil && tad.expertRatings!.count > 0) {
                for rating in tad.expertRatings! {
                    let date = rating.stockRating?.date
                    if date != nil {
                        let today = Date()
                        let ratingDate = GeneralUtility.stringToDate(date!)
                        if ratingDate != nil {
                            let diff = today.interval(ofComponent: .day, fromDate: ratingDate!)
                            totalDays += Double(diff)
                        }
                    }
                }
                avgFreshness = totalDays / Double(tad.expertRatings!.count)
            }
            if self.stockExtraData[tad.symbol!] != nil {
                self.stockExtraData[tad.symbol!]!.freshness = avgFreshness
            }
        }
        self.topAnalystDataAll = self.topAnalystDataAll.filter({ p in
            p.numAnalysts ?? 0 > 1
        })
        var symbolSet:Set<String> = []
        for a in self.topAnalystDataAll {
            symbolSet.insert(a.symbol!)
        }
        NetworkManager.getMyRestApi().getQuotes(symbols: Array(symbolSet), completionHandler: handleLatestQuotes)
    }
    
    private func handleLatestQuotes(quotes:[Quote]){
        var newAnalystSymbolList:[PriceTargetTopAnalysts] = []
        for quote in quotes {
            if quote.symbol != nil {
                for var item in self.topAnalystDataAll {
                    if quote.symbol?.uppercased() == item.symbol?.uppercased() && item.avgPriceTarget != nil && quote.latestPrice != nil{
                        item.upsidePercent = ((item.avgPriceTarget! - quote.latestPrice!) / quote.latestPrice!) * 100.0
                        
                        if self.stockExtraData[quote.symbol!] != nil {
                            self.stockExtraData[quote.symbol!]!.latestPrice = quote.latestPrice!
                            self.computeTotalScore(quote.symbol!, mainDataObj: item, extraData: self.stockExtraData[quote.symbol!]!)
                        }
                        newAnalystSymbolList.append(item)
                        break
                    }
                }
            }
        }
        
        self.topAnalystDataAll = newAnalystSymbolList
        NetworkManager.getMyRestApi().getFidelityAnalysts(completionHandler: handleFidelityScores)
    }
    
    private func handleFidelityScores(_ scores:[FidelityScore]) {
        for score in scores {
            if score.symbol != nil && self.stockExtraData.keys.contains(score.symbol!) {
                self.fidelityScoreDic[score.symbol!] = score
                if self.stockExtraData[score.symbol!] != nil {
                    self.stockExtraData[score.symbol!]!.totalScore += Double(score.score!) ?? 0.0
                }
            }
        }
        self.topAnalystDataAll.sort(by: { (a, b) -> Bool in
            return self.stockExtraData[a.symbol!]!.totalScore > self.stockExtraData[b.symbol!]!.totalScore
        })
        self.topAnalystDataToShow = self.topAnalystDataAll
        DispatchQueue.main.async {
            self.loader.isHidden = true
            self.tableView.reloadData()
        }
    }
    
    private func computeTotalScore(_ symbol:String, mainDataObj: PriceTargetTopAnalysts, extraData:StockExtraAnalystData) {
        let numAnalysts:Double = Double(mainDataObj.numAnalysts ?? 0)
        let avgUpside:Double = mainDataObj.upsidePercent ?? 0.0 //is already *100
        let avgRank:Double = mainDataObj.avgAnalystRank ?? 0.0
        let numRatings:Double = Double(mainDataObj.numRatings ?? 0) / numAnalysts
        let avgSuccessRate:Double = mainDataObj.avgAnalystSuccessRate ?? 0.0 //decimal form
        let freshness:Double = extraData.freshness //could be nil
        
        let numAnalystsScore = self.computeNumAnalystsScore(numAnalysts)
        let avgUpsideScore = self.computeUpsideScore(avgUpside)
        let rankScore = self.computeRankScore(avgRank)
        let numRatingsScore = self.computeNumRatingsScore(numRatings)
        let avgSuccessScore = (avgSuccessRate*100.0)/20.0
        let freshnessScore = self.computeFreshnessScore(freshness)
        
        let scoreDict:[String:Double] = [
            "numAnalysts": numAnalysts,
            "avgRank": avgRank,
            "priceTarget": avgUpside,
            "freshness": freshness,
            "numRatings": numRatings
        ]
        for key in scoreDict.keys {
            self.setMinMax(key, metricValue: scoreDict[key]!)
        }
        
        let totalScore = numAnalystsScore + avgUpsideScore + rankScore + numRatingsScore + avgSuccessScore + freshnessScore
        self.stockExtraData[symbol]!.totalScore = totalScore
    }

    private func setMinMax(_ metricName:String, metricValue:Double) {
        if self.minMaxes[metricName] != nil {
            if metricValue < self.minMaxes[metricName]!.mini {
                self.minMaxes[metricName]!.mini = metricValue
            }
            if metricValue > self.minMaxes[metricName]!.maxi {
                self.minMaxes[metricName]!.maxi = metricValue
            }
        }
    }
    
    private func computeNumAnalystsScore(_ numAnalysts:Double) -> Double {
        return numAnalysts*2.0
    }
    private func computeUpsideScore(_ upside:Double) -> Double {
        var s = upside/3.0
        if (s > 15) {
            s = 15
        }
        return s
    }
    private func computeRankScore(_ rank:Double) -> Double {
        var s = (1.0/rank)*15.0
        if s > 3 { s = 3 }
        return s
    }
    private func computeNumRatingsScore(_ numRatings:Double) -> Double {
        var s = numRatings / 6
        if s > 5 { s = 5 }
        return s
    }
    private func computeFreshnessScore(_ freshness:Double) -> Double {
        var s = (1.0/freshness)*100.0
        if s > 8 {
            s = 8
        }
        return s
    }
    
    func getScoreTextColor(_ val:Double) -> UIColor {
        let blue:CGFloat = 0.0
        var red:CGFloat = 0.0
        var green:CGFloat = 0.0
        if val <= 0.5 {
            red = 218.0
            green = CGFloat((val/0.5) * 218.0)
        } else {
            green = 218.0
            let subtract = ((val - 0.75)/0.25) * 218.0
            red = CGFloat(218.0 - subtract)
        }
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1.0)
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? ExpertsViewController {
            if let ss = self.selectedSymbol {
                dest.experts = ss.expertRatings ?? []
            
                dest.latestPrice = self.stockExtraData[ss.symbol!]!.latestPrice ?? 0.0
                dest.symbol = ss.symbol?.uppercased() ?? ""
                dest.companyName = ""
                dest.companyLogo = ""
            }
        }
    }
    

}
