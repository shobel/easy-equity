//
//  PredictionsViewController.swift
//  stonks
//
//  Created by Samuel Hobel on 8/25/19.
//  Copyright © 2019 Samuel Hobel. All rights reserved.
//

import UIKit

class PredictionsViewController: UIViewController, StatsVC {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var priceTargetChartView: PriceTargetChart!
    @IBOutlet weak var ratingsChartView: RatingsChart!
    
    @IBOutlet weak var lowTarget: ColoredComparisonLabel!
    @IBOutlet weak var avgTarget: ColoredComparisonLabel!
    @IBOutlet weak var highTarget: ColoredComparisonLabel!
    
    @IBOutlet weak var numAnalysts: UILabel!
    @IBOutlet weak var updateDate: UILabel!
    
    @IBOutlet weak var overallRatingsView: UIView!
    @IBOutlet weak var overallPercent: UILabel!
    @IBOutlet weak var overallLabel: UILabel!
    
    private var company:Company!
    private var isLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.company = Dataholder.selectedCompany!
        self.isLoaded = true
        self.overallRatingsView.layer.cornerRadius = self.overallRatingsView.frame.width/2 + 5
        self.overallRatingsView.layer.masksToBounds = true
        self.overallRatingsView.clipsToBounds = true
        updateData();
    }
    
    func updateData() {
        self.company = Dataholder.selectedCompany!
        if (isLoaded) {
            self.priceTargetChartView.setup(company: self.company, predictionsDelegate: self)
            self.ratingsChartView.setup(company: self.company, predictionsDelegate: self)
            let latestPrice = self.company.quote?.latestPrice
            if let x = self.company.priceTarget?.priceTargetHigh {
                self.highTarget.setValue(value: x, comparisonValue: latestPrice!)
            }
            if let x = self.company.priceTarget?.priceTargetAverage {
                self.avgTarget.setValue(value: x, comparisonValue: latestPrice!)
            }
            if let x = self.company.priceTarget?.priceTargetLow {
                self.lowTarget.setValue(value: x, comparisonValue: latestPrice!)
            }
            if let x = self.company.priceTarget?.numberOfAnalysts {
                let analystString = x > 1 ? "analysts" : "analyst"
                self.numAnalysts.text = String("\(x) \(analystString)")
            }
            if let x = self.company.priceTarget?.updatedDate {
                self.updateDate.text = NumberFormatter.formatDate(x)
            }
            if let x = self.company.recommendations?.ratingScaleMark {
                self.overallPercent.text = String(format: "%.2f", "\((x / 3)*100)")
                var overallText = ""
                if x <= 1 {
                    overallText = "Strong Buy"
                } else if x <= 1.5 {
                    overallText = "Buy"
                } else if x <= 2 {
                    overallText = "Hold"
                } else if x <= 2.5 {
                    overallText = "Sell"
                } else if x <= 3 {
                    overallText = "Strong Sell"
                }
                self.overallLabel.text = overallText
            }
        }

    }
    
    func getContentHeight() -> CGFloat {
        if isLoaded {
            return self.contentView.bounds.height
        }
        return 0.0
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
