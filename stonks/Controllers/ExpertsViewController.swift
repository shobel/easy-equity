//
//  ExpertsViewController.swift
//  stonks
//
//  Created by Samuel Hobel on 5/13/21.
//  Copyright © 2021 Samuel Hobel. All rights reserved.
//

import UIKit

class ExpertsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var expertsTable: UITableView!
    
    public var experts:[ExpertAndRatingForStock] = []
    public var latestPrice:Double?
    public var symbol:String = ""
    public var companyName:String = ""
    public var companyLogo:String = ""
    
    override func viewDidLoad() {
        self.expertsTable.delegate = self
        self.expertsTable.dataSource = self
        
        self.experts.sort { expert1, expert2 in
            return expert1.rank ?? 0 < expert2.rank ?? 0
        }

        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //self.expertsTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return experts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "expertAndRatingCell") as! ExpertAndRatingTableViewCell
        let expert = experts[indexPath.row]
        cell.analystNameLabel.text = expert.name
        if let rank = expert.rank {
            cell.rankLabel.text = String("Rank #\(rank)")
        }
        if var type = expert.type, let firm = expert.firm {
            type = type.capitalized(with: .current)
            if let sector = expert.sector {
                cell.typeAndFirmLabel.text = String("\(type) of \(sector) at \(firm)")
            } else {
                cell.typeAndFirmLabel.text = String("\(type) at \(firm)")
            }
        }

        if let pt = expert.stockRating?.priceTarget {
            if self.latestPrice != nil && latestPrice != 0.0 {
                let percentOff = ((pt - latestPrice!)/latestPrice!)*100.0
                let percentOffString = String(format: "%.0f", percentOff)
                if percentOff > 0 {
                    cell.ptPercentOff.text = String(" (+\(percentOffString)%)")
                    cell.ptPercentOff.textColor = Constants.green
//                    cell.priceTargetLabel.textColor = Constants.green
                } else if percentOff < 0{
                    cell.ptPercentOff.text = String(" (\(percentOffString)%)")
                    cell.ptPercentOff.textColor = Constants.darkPink
//                    cell.priceTargetLabel.textColor = Constants.darkPink
                } else {
                    cell.ptPercentOff.textColor = Constants.darkGrey
//                    cell.priceTargetLabel.textColor = Constants.darkGrey
                }
            }
            cell.priceTargetLabel.text = String("$\(pt)")
        } else {
            cell.priceTargetLabel.text = String("- -")
            cell.ptPercentOff.text = String("")
        }
        cell.overallReturn.setProgressAndLabel(CGFloat((expert.avgReturn ?? 0.0)/0.4), label: String(Int(((expert.avgReturn ?? 0.0)*100).rounded())) + "%")
        cell.overallReturn.setProgressColor(self.getTintColorForReturnValue(value: Float(expert.avgReturn ?? 0.0)))
        cell.overallSuccessRate.setProgress(CGFloat(expert.successRate ?? 0.0))
        cell.overallSuccessRate.setProgressColor(self.getTintColorForProgressValue(value: Float(expert.successRate ?? 0.0)))
        cell.stockReturn.setProgressAndLabel(CGFloat((expert.stockRating?.averageReturn ?? 0.0)/0.4), label: String(Int(((expert.stockRating?.averageReturn ?? 0.0)*100).rounded())) + "%")
        cell.stockReturn.setProgressColor(self.getTintColorForReturnValue(value: Float(expert.stockRating?.averageReturn ?? 0.0)))
        cell.stockSuccessRate.setProgress(CGFloat(expert.stockRating?.successRate ?? 0.0))
        cell.stockSuccessRate.setProgressColor(self.getTintColorForProgressValue(value: Float(expert.stockRating?.successRate ?? 0.0)))
            
        if let overallNumRatings = expert.numRatings {
            cell.overallNumRatings.text = String("Overall: \(overallNumRatings) ratings")
        }
        if let stockNumRatings = expert.stockRating?.numRatings {
            cell.stockNumRatings.text = String("This stock: \(stockNumRatings) ratings")
        }
        cell.stars.rating = expert.stars ?? 5.0
        if let pos = expert.stockRating?.position {
            cell.positionLabel.text = pos.uppercased()
            cell.positionLabelContainer.backgroundColor = self.getColorForRating(value: pos)
        }
        return cell
    }
    
    func getTintColorForReturnValue(value:Float) -> UIColor {
        if value > 0.25 {
//            return Constants.green
            return Constants.blue
        } else if value > 0.1 {
//            return Constants.yellow
            return Constants.purple
        } else {
//            return Constants.darkPink
            return Constants.bigRed
        }
    }
    func getTintColorForProgressValue(value:Float) -> UIColor {
        if value > 0.7 {
//            return Constants.green
            return Constants.blue
        } else if value > 0.4 {
//            return Constants.yellow
            return Constants.purple
        } else {
//            return Constants.darkPink
            return Constants.bigRed
        }
    }
    func getColorForRating(value:String) -> UIColor {
        let lowercasedValue = value.lowercased()
        if lowercasedValue == "buy" {
            return Constants.green
        } else if lowercasedValue == "hold"{
            return Constants.yellow
        } else if lowercasedValue == "sell" {
            return Constants.darkPink
        }
        return .black
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
