//
//  EarningsViewController.swift
//  stonks
//
//  Created by Samuel Hobel on 9/8/19.
//  Copyright © 2019 Samuel Hobel. All rights reserved.
//

import UIKit
import XLActionController

class ScoresViewController: UIViewController, StatsVC {
    
    private var company:Company!
    private var isLoaded = false
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var rankContainer: UIView!
    @IBOutlet weak var overallScoreContainer: UIView!
    @IBOutlet weak var overallScore: UILabel!
    @IBOutlet weak var rank: UILabel!
    @IBOutlet weak var industryRankContainer: UIView!
    @IBOutlet weak var industryRank: UILabel!
    @IBOutlet weak var industryLabel: UILabel!
    @IBOutlet weak var industryTotal: UILabel!
    
    @IBOutlet weak var overallValuationScore: UILabel!
    @IBOutlet weak var peRatioScore: UILabel!
    @IBOutlet weak var epsTTMScore: UILabel!
    @IBOutlet weak var psScore: UILabel!
    @IBOutlet weak var pbScore: UILabel!
    
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
    
    @IBOutlet weak var peRatioValue: UILabel!
    @IBOutlet weak var epsValue: UILabel!
    @IBOutlet weak var psValue: UILabel!
    @IBOutlet weak var pbValue: UILabel!

    @IBOutlet weak var pegValue: UILabel!
    @IBOutlet weak var epsConsensusValue: UILabel!
    @IBOutlet weak var priceTargetsValue: UILabel!
    @IBOutlet weak var recommendationsValue: UILabel!
    
    @IBOutlet weak var incomeGrowthValue: UILabel!
    @IBOutlet weak var incomeGrowthAccelValue: UILabel!
    @IBOutlet weak var revenueGrowthValue: UILabel!
    @IBOutlet weak var revGrowthAccelValue: UILabel!
    @IBOutlet weak var profitMarginGrowthValue: UILabel!
    @IBOutlet weak var cashflowGrowthValue: UILabel!
    @IBOutlet weak var oneYearPerfValue: UILabel!
    
    @IBOutlet weak var roeValue: UILabel!
    @IBOutlet weak var assetLiabilityValue: UILabel!
    @IBOutlet weak var debtEquityValue: UILabel!
    @IBOutlet weak var debtAssetValue: UILabel!
    @IBOutlet weak var cashflowDebtValue: UILabel!
    @IBOutlet weak var dividendValue: UILabel!
    @IBOutlet weak var tutesValue: UILabel!
    @IBOutlet weak var insiderValues: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isLoaded = true
        self.company = Dataholder.selectedCompany!
        self.rankContainer.layer.cornerRadius = self.rankContainer.frame.width/2
        self.rankContainer.layer.masksToBounds = true
        self.rankContainer.clipsToBounds = true
        
        self.industryRankContainer.layer.cornerRadius = self.industryRankContainer.frame.width/2
        self.industryRankContainer.layer.masksToBounds = true
        self.industryRankContainer.clipsToBounds = true
        
        self.overallScoreContainer.layer.cornerRadius = self.overallScoreContainer.frame.width/2
        self.overallScoreContainer.layer.masksToBounds = true
        self.overallScoreContainer.clipsToBounds = true
        updateData()
    }
    
    @IBAction func moreButtonAction(_ sender: Any) {
        let actionController = SkypeActionController() //not really for skype
        actionController.addAction(Action("Configure Scores", style: .default, handler: { action in
            
        }))
        actionController.addAction(Action("Search By Score", style: .default, handler: { action in

        }))
        actionController.addAction(Action("What Do The Scores Mean?", style: .default, handler: { action in
            
        }))
        actionController.addAction(Action("Suggest A Metric", style: .default, handler: { action in
            
        }))
        present(actionController, animated: true, completion: nil)
    }
    
    func updateData() {
        self.company = Dataholder.selectedCompany!
        if (isLoaded){
            DispatchQueue.main.async {
                if let scores = self.company.scores, let percentile = self.company.scores?.percentile, let rank = self.company.scores?.rank {
                    let stringVal = String(format: "%.0f", percentile * 100.0)
                    self.overallScore.text = String("\(stringVal)%")
                    self.overallScore.textColor = self.getTintColorForProgressValue(value: Float(percentile))
                    self.overallScoreContainer.backgroundColor = self.getTintColorForProgressValue(value: Float(percentile)).withAlphaComponent(0.2)

                    self.rankContainer.backgroundColor = self.getTintColorForProgressValue(value: Float(percentile)).withAlphaComponent(0.2)
                    self.rank.text = String("#\(scores.rank ?? 0)")
                    self.rank.textColor = self.getTintColorForProgressValue(value: Float(percentile))
                    
                    self.industryRank.text = String("#\(scores.industryRank ?? 0)")
                    let industryRankPercent:Float = 1.0 - Float((Float(scores.industryRank ?? 0))/(Float(scores.industryTotal ?? 0)))
                    self.industryRankContainer.backgroundColor = self.getTintColorForProgressValue(value: industryRankPercent).withAlphaComponent(0.2)
                    self.industryRank.textColor = self.getTintColorForProgressValue(value: industryRankPercent)
                    
                    self.industryLabel.text = "IND: " + (scores.industry ?? "")
                    self.industryTotal.text = String("of \(scores.industryTotal ?? 0)")
                    let rawValues = scores.rawValues!
                    if let valuationScores = self.company.scores?.valuation {
                        for (key, value) in valuationScores {
                            let scoreString = String(format: "%.1f", value * 100.0) + "%"
                            let scoreColor = self.getScoreTextColor(value)
                            let valueString = String(format: "%.1f", rawValues[key] ?? 0.0)
                            switch key {
                                case "overall":
                                    self.overallValuationScore.text = scoreString
                                    self.overallValuationScore.textColor = scoreColor
                                    break
                                case "peRatio":
                                    self.peRatioScore.text = scoreString
                                    self.peRatioScore.textColor = scoreColor
                                    self.peRatioValue.text = valueString
                                    break
                                case "epsTTM":
                                    self.epsTTMScore.text = scoreString
                                    self.epsTTMScore.textColor = scoreColor
                                    self.epsValue.text = valueString
                                    break
                                case "priceToSales":
                                    self.psScore.text = scoreString
                                    self.psScore.textColor = scoreColor
                                    self.psValue.text = valueString
                                    break
                                case "priceToBook":
                                    self.pbScore.text = scoreString
                                    self.pbScore.textColor = scoreColor
                                    self.pbValue.text = valueString
                                    break
                                default:
                                    break
                            }
                        }
                    }
                    
                    if let futureScores = self.company.scores?.futureGrowth {
                        for (key, value) in futureScores {
                            let scoreString = String(format: "%.1f", value * 100.0) + "%"
                            let scoreColor = self.getScoreTextColor(value)
                            let valueString = String(format: "%.1f", rawValues[key] ?? 0.0)
                            switch key {
                                case "overall":
                                    self.overallFutureScore.text = scoreString
                                    self.overallFutureScore.textColor = scoreColor
                                    break
                                case "pegRatio":
                                    self.pegScore.text = scoreString
                                    self.pegScore.textColor = scoreColor
                                    self.pegValue.text = valueString
                                    break
                                case "epsNextQGrowth":
                                    self.epsNextQuarterScore.text = scoreString
                                    self.epsNextQuarterScore.textColor = scoreColor
                                    self.epsConsensusValue.text = valueString
                                    break
                                case "priceTargetScore":
                                    self.priceTargetScore.text = scoreString
                                    self.priceTargetScore.textColor = scoreColor
                                    self.priceTargetsValue.text = valueString
                                    break
                                case "recommendationScore":
                                    self.recommendationsScore.text = scoreString
                                    self.recommendationsScore.textColor = scoreColor
                                    self.recommendationsValue.text = valueString
                                    break
                                default:
                                    break
                            }
                        }
                    }
                    
                    if let pastScores = self.company.scores?.pastPerformance {
                        for (key, value) in pastScores {
                            let scoreString = String(format: "%.1f", value * 100.0) + "%"
                            let scoreColor = self.getScoreTextColor(value)
                            let valueString = String(format: "%.1f", (rawValues[key] ?? 0.0) * 100.0) + "%"
                            switch key {
                                case "overall":
                                    self.overallPastScore.text = scoreString
                                    self.overallPastScore.textColor = scoreColor
                                    break
                                case "avgRevenueGrowth":
                                    self.revenueGrowthScore.text = scoreString
                                    self.revenueGrowthScore.textColor = scoreColor
                                    self.revenueGrowthValue.text = valueString
                                    break
                                case "avgIncomeGrowth":
                                    self.incomeGrowthScore.text = scoreString
                                    self.incomeGrowthScore.textColor = scoreColor
                                    self.incomeGrowthValue.text = valueString
                                    break
                                case "revenueGrowthRate":
                                    self.revenueGrowthRateScore.text = scoreString
                                    self.revenueGrowthRateScore.textColor = scoreColor
                                    self.revGrowthAccelValue.text = valueString
                                    break
                                case "incomeGrowthRate":
                                    self.incomeGrowthRateScore.text = scoreString
                                    self.incomeGrowthRateScore.textColor = scoreColor
                                    self.incomeGrowthAccelValue.text = valueString
                                    break
                                case "cashFlowGrowth":
                                    self.cashFlowGrowthScore.text = scoreString
                                    self.cashFlowGrowthScore.textColor = scoreColor
                                    self.cashflowGrowthValue.text = valueString
                                    break
                                case "profitMarginGrowth":
                                    self.profitMarginGrowthScore.text = scoreString
                                    self.profitMarginGrowthScore.textColor = scoreColor
                                    self.profitMarginGrowthValue.text = valueString
                                    break
                                case "oneYearChange":
                                    self.OneYearScore.text = scoreString
                                    self.OneYearScore.textColor = scoreColor
                                    self.oneYearPerfValue.text = valueString
                                    break
                                default:
                                    break
                            }
                        }
                    }
                    
                    if let healthScores = self.company.scores?.financialHealth {
                        for (key, value) in healthScores {
                            let scoreString = String(format: "%.1f", value * 100.0) + "%"
                            let scoreColor = self.getScoreTextColor(value)
                            let valueString = String(format: "%.1f", rawValues[key] ?? 0.0)
                            let valueStringPercent = String(format: "%.1f", (rawValues[key] ?? 0.0) * 100.0) + "%"
                            switch key {
                                case "overall":
                                    self.overallHealthScore.text = scoreString
                                    self.overallHealthScore.textColor = scoreColor
                                    break
                                case "debtToAssets":
                                    self.debtAssetsScore.text = scoreString
                                    self.debtAssetsScore.textColor = scoreColor
                                    self.debtAssetValue.text = valueString
                                    break
                                case "debtToEquity":
                                    self.debtEquityScore.text = scoreString
                                    self.debtEquityScore.textColor = scoreColor
                                    self.debtEquityValue.text = valueString
                                    break
                                case "returnOnEquity":
                                    self.roeScore.text = scoreString
                                    self.roeScore.textColor = scoreColor
                                    self.roeValue.text = valueStringPercent
                                    break
                                case "insiders":
                                    self.insiderScore.text = scoreString
                                    self.insiderScore.textColor = scoreColor
                                    self.insiderValues.text = String(NumberFormatter.formatNumber(num: Double(valueString)!))
                                    break
                                case "tutes":
                                    self.tutesScore.text = scoreString
                                    self.tutesScore.textColor = scoreColor
                                    self.tutesValue.text = valueStringPercent
                                    break
                                case "assetsLiabilities":
                                    self.assetsLiabilitiesScore.text = scoreString
                                    self.assetsLiabilitiesScore.textColor = scoreColor
                                    self.assetLiabilityValue.text = valueString
                                    break
                                case "cashflowDebt":
                                    self.cashFlowDebtScore.text = scoreString
                                    self.cashFlowDebtScore.textColor = scoreColor
                                    self.cashflowDebtValue.text = valueString
                                    break
                                case "dividendYield":
                                    self.dividendScore.text = scoreString
                                    self.dividendScore.textColor = scoreColor
                                    self.dividendValue.text = valueStringPercent
                                    break
                                default:
                                    break
                            }
                        }
                    }
                    
                    if let technicals = self.company.scores?.technical {
                        for (key, value) in technicals {
                            let scoreString = String(format: "%.1f", value * 100.0) + "%"
                            let scoreColor = self.getScoreTextColor(value)
                            switch key {
                                case "overall":
                                    self.overallTechnicalScore.text = scoreString
                                    self.overallTechnicalScore.textColor = scoreColor
                                    break
                                case "support":
                                    self.supportScore.text = scoreString
                                    self.supportScore.textColor = scoreColor
                                    break
                                case "pressure":
                                    self.gapScore.text = scoreString
                                    self.gapScore.textColor = scoreColor
                                    break
                                case "trends":
                                    self.trendsScore.text = scoreString
                                    self.trendsScore.textColor = scoreColor
                                    break
                                case "momentum":
                                    self.momentumScore.text = scoreString
                                    self.momentumScore.textColor = scoreColor
                                    break
                                case "circuitBreaker":
                                    self.ssrScore.text = scoreString
                                    self.ssrScore.textColor = scoreColor
                                    break
                                case "strength":
                                    self.rsiScore.text = scoreString
                                    self.rsiScore.textColor = scoreColor
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
    
    
    
    func getScoreTextColor(_ val:Double) -> UIColor {
        let blue:CGFloat = 0.0
        var red:CGFloat = 0.0
        var green:CGFloat = 0.0
        if val <= 0.5 {
            red = 218.0
            green = CGFloat((val/0.5) * 218.0)
        } else {
            green = 218.0
            red = CGFloat(218.0 - ((val - 0.5)/0.5) * 218.0)
        }
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1.0)
    }
    
    func getTintColorForProgressValue(value:Float) -> UIColor {
//        if value > 0.7 {
//            return Constants.green
//        } else if value > 0.4 {
//            return Constants.yellow
//        } else {
//            return Constants.darkPink
//        }
        let blue:CGFloat = 0.0
        var red:CGFloat = 0.0
        var green:CGFloat = 0.0
        if value <= 0.5 {
            red = 218.0
            green = CGFloat((value/0.5) * 218.0)
        } else {
            green = 218.0
            red = CGFloat(218.0 - ((value - 0.5)/0.5) * 218.0)
        }
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1.0)
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
