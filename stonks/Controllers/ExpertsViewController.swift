//
//  ExpertsViewController.swift
//  stonks
//
//  Created by Samuel Hobel on 5/13/21.
//  Copyright © 2021 Samuel Hobel. All rights reserved.
//

import UIKit
import XLActionController

class ExpertsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var expertsTable: UITableView!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var latestPriceLabel: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var sortByContainer: UIView!
    
    public var experts:[ExpertAndRatingForStock] = []
    public var latestPrice:Double?
    public var symbol:String = ""
    public var companyName:String = ""
    public var companyLogo:String = ""
    
    override func viewDidLoad() {
        self.expertsTable.delegate = self
        self.expertsTable.dataSource = self
        self.sortByContainer.layer.cornerRadius = 5.0
        self.experts.sort { expert1, expert2 in
            return expert1.rank ?? 0 < expert2.rank ?? 0
        }

        self.symbolLabel.text = self.symbol
        self.companyNameLabel.text = self.companyName
        if let latestPrice = self.latestPrice {
            self.latestPriceLabel.text = String("$\(self.latestPrice!)")
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
        if let name = expert.name {
            cell.analystNameLabel.text = expert.name
            if name.contains(" "){
                let firstName:String = String(name.split(separator: " ")[0])
                let lastName:String = String(name.split(separator: " ")[1])
                if let firstLetterLast = lastName.first {
                    cell.analystNameLabel.text = firstName + " " + String(firstLetterLast)
                } else {
                    cell.analystNameLabel.text = firstName
                }
            }
        }
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
            cell.stockNumRatings.text = String("On \(self.symbol): \(stockNumRatings) ratings")
        }
        cell.stars.rating = expert.stars ?? 5.0
        if let pos = expert.stockRating?.position {
            cell.positionLabel.text = pos.uppercased()
            cell.positionLabelContainer.backgroundColor = self.getColorForRating(value: pos)
        }
        if let date = expert.stockRating?.date {
            cell.date.text = date
        }
        return cell
    }
    
    func getTintColorForReturnValue(value:Float) -> UIColor {
        if value > 0.3 {
            return UIColor(red: 80.0/255.0, green: 50.0/255.0, blue: 250.0/255.0, alpha: 1.0)
        } else if value > 0.2 {
            return UIColor(red: 120.0/255.0, green: 50.0/255.0, blue: 230.0/255.0, alpha: 1.0)
        } else if value > 0.1 {
            return UIColor(red: 160.0/255.0, green: 53.0/255.0, blue: 210.0/255.0, alpha: 1.0)
        } else {
            return UIColor(red: 200.0/255.0, green: 60.0/255.0, blue: 168.0/255.0, alpha: 1.0)
        }
    }
    func getTintColorForProgressValue(value:Float) -> UIColor {
        if value > 0.75 {
            return UIColor(red: 80.0/255.0, green: 50.0/255.0, blue: 250.0/255.0, alpha: 1.0)
        } else if value > 0.5 {
            return UIColor(red: 120.0/255.0, green: 50.0/255.0, blue: 230.0/255.0, alpha: 1.0)
        } else if value > 0.25 {
            return UIColor(red: 160.0/255.0, green: 53.0/255.0, blue: 210.0/255.0, alpha: 1.0)
        } else {
            return UIColor(red: 200.0/255.0, green: 60.0/255.0, blue: 168.0/255.0, alpha: 1.0)
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
    
    @IBAction func sortByButtonTapped(_ sender: Any) {
        let actionController = SkypeActionController() //not really for skype
        actionController.addAction(Action("Analyst Rank", style: .default, handler: { action in
            self.experts.sort { expert1, expert2 in
                return expert1.rank ?? 0 < expert2.rank ?? 0
            }
            self.expertsTable.reloadData()
        }))
        actionController.addAction(Action("Overall success rate", style: .default, handler: { action in
            self.experts.sort { expert1, expert2 in
                return expert1.successRate ?? 0.0 > expert2.successRate ?? 0.0
            }
            self.expertsTable.reloadData()
        }))
        actionController.addAction(Action("Overall average return", style: .default, handler: { action in
            self.experts.sort { expert1, expert2 in
                return expert1.avgReturn ?? 0.0 > expert2.avgReturn ?? 0.0
            }
            self.expertsTable.reloadData()
        }))
        actionController.addAction(Action("Success rate on " + self.symbol, style: .default, handler: { action in
            self.experts.sort { expert1, expert2 in
                return expert1.stockRating?.successRate ?? 0.0 > expert2.stockRating?.successRate ?? 0.0
            }
            self.expertsTable.reloadData()
        }))
        actionController.addAction(Action("Average return on " + self.symbol, style: .default, handler: { action in
            self.experts.sort { expert1, expert2 in
                return expert1.stockRating?.averageReturn ?? 0.0 > expert2.stockRating?.averageReturn ?? 0.0
            }
            self.expertsTable.reloadData()
        }))
        actionController.addAction(Action("Number of ratings", style: .default, handler: { action in
            self.experts.sort { expert1, expert2 in
                return expert1.numRatings ?? 0 > expert2.numRatings ?? 0
            }
            self.expertsTable.reloadData()
        }))
        actionController.addAction(Action("Number of ratings on " + self.symbol, style: .default, handler: { action in
            self.experts.sort { expert1, expert2 in
                return expert1.stockRating?.numRatings ?? 0 > expert2.stockRating?.numRatings ?? 0
            }
            self.expertsTable.reloadData()
        }))
        actionController.addAction(Action("Rating date", style: .default, handler: { action in
            self.experts.sort { expert1, expert2 in
                return expert1.stockRating?.timestamp ?? 0 > expert2.stockRating?.timestamp ?? 0
            }
            self.expertsTable.reloadData()
        }))
        actionController.addAction(Action("Price target for " + self.symbol, style: .default, handler: { action in
            self.experts.sort { expert1, expert2 in
                return expert1.stockRating?.priceTarget ?? 0 > expert2.stockRating?.priceTarget ?? 0
            }
            self.expertsTable.reloadData()
        }))
        present(actionController, animated: true, completion: nil)
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
