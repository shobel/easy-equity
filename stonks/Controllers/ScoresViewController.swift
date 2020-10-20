//
//  EarningsViewController.swift
//  stonks
//
//  Created by Samuel Hobel on 9/8/19.
//  Copyright © 2019 Samuel Hobel. All rights reserved.
//

import UIKit

class ScoresViewController: UIViewController, StatsVC {
    
    private var company:Company!
    private var isLoaded = false
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var overallScoreContainer: UIView!
    @IBOutlet weak var overallScore: UILabel!
    
    @IBOutlet weak var overallValuationScore: UILabel!
    @IBOutlet weak var peRatioScore: UILabel!
    @IBOutlet weak var epsTTMScore: UILabel!
    @IBOutlet weak var psScore: UILabel!
    @IBOutlet weak var pbScore: UILabel!
    @IBOutlet weak var dcfScore: UILabel!
    
    @IBOutlet weak var overallFutureScore: UILabel!
    @IBOutlet weak var pegScore: UILabel!
    @IBOutlet weak var epsNextQuarterScore: UILabel!
    @IBOutlet weak var priceTargetScore: UILabel!
    @IBOutlet weak var recommendationsScore: UILabel!
    
    @IBOutlet weak var overallPastScore: UILabel!
    @IBOutlet weak var incomeGrowthScore: UILabel!
    @IBOutlet weak var incomeGrowthRateScore: UILabel!
    @IBOutlet weak var revenueGrowthScore: UILabel!
    @IBOutlet weak var revenueGrowthRateScore: UILabel!
    @IBOutlet weak var profitMarginGrowthScore: UILabel!
    @IBOutlet weak var cashFlowGrowthScore: UILabel!
    @IBOutlet weak var OneYearScore: UILabel!
    
    @IBOutlet weak var overallHealthScore: UILabel!
    @IBOutlet weak var roeScore: UILabel!
    @IBOutlet weak var assetsLiabilitiesScore: UILabel!
    @IBOutlet weak var debtEquityScore: UILabel!
    @IBOutlet weak var debtAssetsScore: UILabel!
    @IBOutlet weak var cashFlowDebtScore: UILabel!
    @IBOutlet weak var dividendScore: UILabel!
    @IBOutlet weak var tutesScore: UILabel!
    @IBOutlet weak var insiderScore: UILabel!

    @IBOutlet weak var overallTechnicalScore: UILabel!
    @IBOutlet weak var trendsScore: UILabel!
    @IBOutlet weak var gapScore: UILabel!
    @IBOutlet weak var supportScore: UILabel!
    @IBOutlet weak var rsiScore: UILabel!
    @IBOutlet weak var momentumScore: UILabel!
    @IBOutlet weak var ssrScore: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isLoaded = true
        self.company = Dataholder.selectedCompany!
        self.overallScoreContainer.layer.cornerRadius = self.overallScoreContainer.frame.width/2
        self.overallScoreContainer.layer.masksToBounds = true
        self.overallScoreContainer.clipsToBounds = true
        updateData()
    }
    
    func updateData() {
        self.company = Dataholder.selectedCompany!
        if (isLoaded){
            DispatchQueue.main.async {
                if let scores = self.company.scores, let percentile = self.company.scores?.percentile {
                    let stringVal = String(format: "%.0f", percentile * 100.0)
                    self.overallScore.text = String("\(stringVal)%")
                    self.overallScore.textColor = self.getTintColorForProgressValue(value: Float(percentile))
                    self.overallScoreContainer.backgroundColor = self.getTintColorForProgressValue(value: Float(percentile)).withAlphaComponent(0.2)
                    
                    if let valuationScores = self.company.scores?.valuation {
                        for (key, value) in valuationScores {
                            let valueString = String(format: "%.1f", value * 100.0) + "%"
                            switch key {
                                case "overall":
                                    self.overallValuationScore.text = valueString
                                    break
                                case "peRatio":
                                    self.peRatioScore.text = valueString
                                    break
                                case "epsTTM":
                                    self.epsTTMScore.text = valueString
                                    break
                                case "priceToSales":
                                    self.psScore.text = valueString
                                    break
                                case "priceToBook":
                                    self.pbScore.text = valueString
                                    break
                                case "priceFairValue":
                                    self.dcfScore.text = valueString
                                    break
                                default:
                                    break
                            }
                        }
                    }
                    
                    if let futureScores = self.company.scores?.futureGrowth {
                        for (key, value) in futureScores {
                            let valueString = String(format: "%.1f", value * 100.0) + "%"
                            switch key {
                                case "overall":
                                    self.overallFutureScore.text = valueString
                                    break
                                case "pegRatio":
                                    self.pegScore.text = valueString
                                    break
                                case "epsNextQGrowth":
                                    self.epsNextQuarterScore.text = valueString
                                    break
                                case "priceTargetScore":
                                    self.priceTargetScore.text = valueString
                                    break
                                case "recommendationScore":
                                    self.recommendationsScore.text = valueString
                                    break
                                default:
                                    break
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getTintColorForProgressValue(value:Float) -> UIColor {
        if value > 0.7 {
            return Constants.green
        } else if value > 0.4 {
            return Constants.yellow
        } else {
            return Constants.darkPink
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
