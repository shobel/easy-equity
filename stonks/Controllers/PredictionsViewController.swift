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
        }
//        if (isLoaded){
//            DispatchQueue.main.async {
//                var numBuy = 0
//                var numSell = 0
//                var numHold = 0
//                if let recommendations = self.company.recommendations {
//                    numBuy += recommendations.ratingBuy! + recommendations.ratingOverweight!
//                    numHold += recommendations.ratingHold!
//                    numSell += recommendations.ratingUnderweight! + recommendations.ratingSell!
//
//                    self.company.totalBuy = numBuy
//                    self.company.totalHold = numHold
//                    self.company.totalSell = numSell
//                }
//                self.numBuys.setValue(value: String(numBuy), format: FormattedNumberLabel.Format.NUMBER)
//                self.numHolds.setValue(value: String(numHold), format: FormattedNumberLabel.Format.NUMBER)
//                self.numSells.setValue(value: String(numSell), format: FormattedNumberLabel.Format.NUMBER)
//
//                if let x = self.company.priceTarget?.priceTargetAverage {
//                    self.priceTarget.setValue(value: String(x), format: FormattedNumberLabel.Format.NUMBER)
//                }
//                if let x = self.company.priceTarget?.numberOfAnalysts {
//                    self.numEstimatesPT.setValue(value: String(x), format: FormattedNumberLabel.Format.NUMBER)
//                }
//                if let x = self.company.priceTarget?.updatedDate {
//                    self.datePT.setValue(value: String(x), format: FormattedNumberLabel.Format.DATE)
//                }
//            }
//        }
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
