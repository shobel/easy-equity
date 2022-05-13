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
    private var scoreSettings:ScoreSettings?
    private var isLoaded = false
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var overallScoreContainer: UIView!
    @IBOutlet weak var overallScore: UILabel!
    @IBOutlet weak var rank: UILabel!
    @IBOutlet weak var industryRank: UILabel!
    
    @IBOutlet weak var scoreSnowflakeChart: ScoreSnowflakeChart!
    
    @IBOutlet weak var valuationWeight: UILabel!
    @IBOutlet weak var overallValuationScore: UILabel!
    @IBOutlet weak var peRatioScore: UILabel!
    @IBOutlet weak var epsTTMScore: UILabel!
    @IBOutlet weak var psScore: UILabel!
    @IBOutlet weak var pbScore: UILabel!
    
    @IBOutlet weak var futureWeight: UILabel!
    @IBOutlet weak var overallFutureScore: UILabel!
    @IBOutlet weak var pegScore: UILabel!
    @IBOutlet weak var epsNextQuarterScore: UILabel!
    @IBOutlet weak var priceTargetScore: UILabel!
    @IBOutlet weak var recommendationsScore: UILabel!
    @IBOutlet weak var estRevScore: UILabel!
    @IBOutlet weak var estEarningsScore: UILabel!
    
    @IBOutlet weak var pastWeight: UILabel!
    @IBOutlet weak var overallPastScore: UILabel!
    @IBOutlet weak var incomeGrowthScore: UILabel!
    @IBOutlet weak var incomeGrowthRateScore: UILabel!
    @IBOutlet weak var revenueGrowthScore: UILabel!
    @IBOutlet weak var revenueGrowthRateScore: UILabel!
    @IBOutlet weak var profitMarginGrowthScore: UILabel!
    @IBOutlet weak var cashFlowGrowthScore: UILabel!
    
    @IBOutlet weak var healthWeight: UILabel!
    @IBOutlet weak var overallHealthScore: UILabel!
    @IBOutlet weak var roeScore: UILabel!
    @IBOutlet weak var debtEquityScore: UILabel!
    @IBOutlet weak var debtAssetsScore: UILabel!
    @IBOutlet weak var cashFlowDebtScore: UILabel!
    @IBOutlet weak var dividendScore: UILabel!
    @IBOutlet weak var tutesScore: UILabel!
    
    @IBOutlet weak var peRatioValue: UILabel!
    @IBOutlet weak var epsValue: UILabel!
    @IBOutlet weak var psValue: UILabel!
    @IBOutlet weak var pbValue: UILabel!

    @IBOutlet weak var pegValue: UILabel!
    @IBOutlet weak var epsConsensusValue: UILabel!
    @IBOutlet weak var priceTargetsValue: UILabel!
    @IBOutlet weak var recommendationsValue: UILabel!
    @IBOutlet weak var estRevGrowthValue: UILabel!
    @IBOutlet weak var estEarningsGrowthValue: UILabel!
    
    @IBOutlet weak var incomeGrowthValue: UILabel!
    @IBOutlet weak var incomeGrowthAccelValue: UILabel!
    @IBOutlet weak var revenueGrowthValue: UILabel!
    @IBOutlet weak var revGrowthAccelValue: UILabel!
    @IBOutlet weak var profitMarginGrowthValue: UILabel!
    @IBOutlet weak var cashflowGrowthValue: UILabel!
    
    @IBOutlet weak var roeValue: UILabel!
    @IBOutlet weak var debtEquityValue: UILabel!
    @IBOutlet weak var debtAssetValue: UILabel!
    @IBOutlet weak var cashflowDebtValue: UILabel!
    @IBOutlet weak var dividendValue: UILabel!
    @IBOutlet weak var tutesValue: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isLoaded = true
        self.company = Dataholder.selectedCompany!
        
        self.overallScoreContainer.layer.cornerRadius = self.overallScoreContainer.frame.width/2
        self.overallScoreContainer.layer.masksToBounds = true
        self.overallScoreContainer.clipsToBounds = true
                
        self.fetchScores()
        self.valuationWeight.text = "25% weight"
        self.futureWeight.text = "25% weight"
        self.pastWeight.text = "25% weight"
        self.healthWeight.text = "25% weight"
    }
    
    public func fetchScores(){
        NetworkManager.getMyRestApi().getScoresForSymbolWithUserSettingsApplied(symbol: self.company.symbol) { (scores, scoreSettings) in
            self.company.scores = scores
            Dataholder.userScoreSettings = scoreSettings
            self.scoreSettings = scoreSettings
            self.updateData()
        }
    }
    
    @IBAction func moreButtonAction(_ sender: Any) {
        let actionController = SkypeActionController() //not really for skype
        actionController.addAction(Action("Configure Scores", style: .default, handler: { action in
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "scoreSettingsVC")
            if let vc = vc as? ScoreSettingsViewController {
                vc.parentVC = self
            }
            self.present(vc, animated: true, completion: nil)
        }))
        actionController.addAction(Action("Search By Score", style: .default, handler: { action in
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "equityScoresVC")
            self.present(vc, animated: true, completion: nil)
        }))
        actionController.addAction(Action("What Do The Scores Mean?", style: .default, handler: { action in
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "scoreDocumentationVC")
            self.present(vc, animated: true, completion: nil)
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

                    self.rank.text = String("#\(scores.rank ?? 0)")
                    self.rank.textColor = self.getTintColorForProgressValue(value: Float(percentile))
                    
                    self.industryRank.text = String("#\(scores.industryRank ?? 0) of \(scores.industryTotal ?? 0)")
                    let industryRankPercent:Float = 1.0 - Float((Float(scores.industryRank ?? 0))/(Float(scores.industryTotal ?? 0)))
 
                    self.industryRank.textColor = self.getTintColorForProgressValue(value: industryRankPercent)
                    
                    var scoresForChart:[Double] = [0.0, 0.0, 0.0, 0.0]
                    let rawValues = scores.rawValues!
                    if let valuationScores = self.company.scores?.valuation {
                        scoresForChart[0] = (valuationScores["overall"] ?? 0.0) * 100.0
                        for (key, value) in valuationScores {
                            let scoreString = String(format: "%.1f", value * 100.0) + "%"
                            var scoreColor = self.getScoreTextColor(value)
                            var valueColor = Constants.darkGrey
                            if let settings = self.scoreSettings, let disabled = settings.disabled {
                                if disabled.contains(key) {
                                    scoreColor = Constants.veryLightGrey
                                    valueColor = Constants.veryLightGrey
                                }
                                if let ws = settings.weightings, let w = ws["valuation"] {
                                    let rounded = String(format: "%.0f", w)
                                    self.valuationWeight.text = String("\(rounded)% weight")
                                }
                            }
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
                                    self.peRatioValue.textColor = valueColor
                                    break
                                case "epsTTM":
                                    self.epsTTMScore.text = scoreString
                                    self.epsTTMScore.textColor = scoreColor
                                    self.epsValue.text = valueString
                                    self.epsValue.textColor = valueColor
                                    break
                                case "priceToSales":
                                    self.psScore.text = scoreString
                                    self.psScore.textColor = scoreColor
                                    self.psValue.text = valueString
                                    self.psValue.textColor = valueColor
                                    break
                                case "priceToBook":
                                    self.pbScore.text = scoreString
                                    self.pbScore.textColor = scoreColor
                                    self.pbValue.text = valueString
                                    self.pbValue.textColor = valueColor
                                    break
                                default:
                                    break
                            }
                        }
                    }
                    
                    if let futureScores = self.company.scores?.futureGrowth {
                        scoresForChart[1] = (futureScores["overall"] ?? 0.0) * 100.0
                        for (key, value) in futureScores {
                            let scoreString = String(format: "%.1f", value * 100.0) + "%"
                            var scoreColor = self.getScoreTextColor(value)
                            var valueColor = Constants.darkGrey
                            if let settings = self.scoreSettings, let disabled = settings.disabled {
                                if disabled.contains(key) {
                                    scoreColor = Constants.veryLightGrey
                                    valueColor = Constants.veryLightGrey
                                }
                                if let ws = settings.weightings, let w = ws["future"] {
                                    let rounded = String(format: "%.0f", w)
                                    self.futureWeight.text = String("\(rounded)% weight")
                                }
                            }
                            let valueString = String(format: "%.1f", rawValues[key] ?? 0.0)
                            let valueStringPercent = String(format: "%.1f", (rawValues[key] ?? 0.0) * 100.0) + "%"
                            switch key {
                                case "overall":
                                    self.overallFutureScore.text = scoreString
                                    self.overallFutureScore.textColor = scoreColor
                                    break
                                case "pegRatio":
                                    self.pegScore.text = scoreString
                                    self.pegScore.textColor = scoreColor
                                    self.pegValue.text = valueString
                                    self.pegValue.textColor = valueColor
                                    break
                                case "epsNextQGrowth":
                                    self.epsNextQuarterScore.text = scoreString
                                    self.epsNextQuarterScore.textColor = scoreColor
                                    self.epsConsensusValue.text = valueString
                                    self.epsConsensusValue.textColor = valueColor
                                    break
                                case "priceTargetScore":
                                    self.priceTargetScore.text = scoreString
                                    self.priceTargetScore.textColor = scoreColor
                                    self.priceTargetsValue.text = valueString
                                    self.priceTargetsValue.textColor = valueColor
                                    break
                                case "recommendationScore":
                                    self.recommendationsScore.text = scoreString
                                    self.recommendationsScore.textColor = scoreColor
                                    self.recommendationsValue.text = valueString
                                    self.recommendationsValue.textColor = valueColor
                                    break
                                case "futureRevenueGrowth":
                                    self.estRevScore.text = scoreString
                                    self.estRevScore.textColor = scoreColor
                                    self.estRevGrowthValue.text = valueStringPercent
                                    self.estRevGrowthValue.textColor = valueColor
                                    break
                                case "futureIncomeGrowth":
                                    self.estEarningsScore.text = scoreString
                                    self.estEarningsScore.textColor = scoreColor
                                    self.estEarningsGrowthValue.text = valueStringPercent
                                    self.estEarningsGrowthValue.textColor = valueColor
                                    break
                                default:
                                    break
                            }
                        }
                    }
                    
                    if let pastScores = self.company.scores?.pastPerformance {
                        scoresForChart[2] = (pastScores["overall"] ?? 0.0) * 100.0
                        for (key, value) in pastScores {
                            let scoreString = String(format: "%.1f", value * 100.0) + "%"
                            var scoreColor = self.getScoreTextColor(value)
                            var valueColor = Constants.darkGrey
                            if let settings = self.scoreSettings, let disabled = settings.disabled {
                                if disabled.contains(key) {
                                    scoreColor = Constants.veryLightGrey
                                    valueColor = Constants.veryLightGrey
                                }
                                if let ws = settings.weightings, let w = ws["past"] {
                                    let rounded = String(format: "%.0f", w)
                                    self.pastWeight.text = String("\(rounded)% weight")
                                }
                            }
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
                                    self.revenueGrowthValue.textColor = valueColor
                                    break
                                case "avgIncomeGrowth":
                                    self.incomeGrowthScore.text = scoreString
                                    self.incomeGrowthScore.textColor = scoreColor
                                    self.incomeGrowthValue.text = valueString
                                    self.incomeGrowthValue.textColor = valueColor
                                    break
                                case "revenueGrowthRate":
                                    self.revenueGrowthRateScore.text = scoreString
                                    self.revenueGrowthRateScore.textColor = scoreColor
                                    self.revGrowthAccelValue.text = valueString
                                    self.revGrowthAccelValue.textColor = valueColor
                                    break
                                case "incomeGrowthRate":
                                    self.incomeGrowthRateScore.text = scoreString
                                    self.incomeGrowthRateScore.textColor = scoreColor
                                    self.incomeGrowthAccelValue.text = valueString
                                    self.incomeGrowthAccelValue.textColor = valueColor
                                    break
                                case "cashFlowGrowth":
                                    self.cashFlowGrowthScore.text = scoreString
                                    self.cashFlowGrowthScore.textColor = scoreColor
                                    self.cashflowGrowthValue.text = valueString
                                    self.cashflowGrowthValue.textColor = valueColor
                                    break
                                case "profitMarginGrowth":
                                    self.profitMarginGrowthScore.text = scoreString
                                    self.profitMarginGrowthScore.textColor = scoreColor
                                    self.profitMarginGrowthValue.text = valueString
                                    self.profitMarginGrowthValue.textColor = valueColor
                                    break
                                default:
                                    break
                            }
                        }
                    }
                    
                    if let healthScores = self.company.scores?.financialHealth {
                        scoresForChart[3] = (healthScores["overall"] ?? 0.0) * 100.0
                        for (key, value) in healthScores {
                            let scoreString = String(format: "%.1f", value * 100.0) + "%"
                            var scoreColor = self.getScoreTextColor(value)
                            let valueString = String(format: "%.1f", rawValues[key] ?? 0.0)
                            let valueStringPercent = String(format: "%.1f", (rawValues[key] ?? 0.0) * 100.0) + "%"
                            var valueColor = Constants.darkGrey
                            if let settings = self.scoreSettings, let disabled = settings.disabled {
                                if disabled.contains(key) {
                                    scoreColor = Constants.veryLightGrey
                                    valueColor = Constants.veryLightGrey
                                }
                                if let ws = settings.weightings, let w = ws["health"] {
                                    let rounded = String(format: "%.0f", w)
                                    self.healthWeight.text = String("\(rounded)% weight")
                                }
                            }
                            switch key {
                                case "overall":
                                    self.overallHealthScore.text = scoreString
                                    self.overallHealthScore.textColor = scoreColor
                                    break
                                case "debtToAssets":
                                    self.debtAssetsScore.text = scoreString
                                    self.debtAssetsScore.textColor = scoreColor
                                    self.debtAssetValue.text = valueString
                                    self.debtAssetValue.textColor = valueColor
                                    break
                                case "debtToEquity":
                                    self.debtEquityScore.text = scoreString
                                    self.debtEquityScore.textColor = scoreColor
                                    self.debtEquityValue.text = valueString
                                    self.debtEquityValue.textColor = valueColor
                                    break
                                case "returnOnEquity":
                                    self.roeScore.text = scoreString
                                    self.roeScore.textColor = scoreColor
                                    self.roeValue.text = valueStringPercent
                                    self.roeValue.textColor = valueColor
                                    break
                                case "tutes":
                                    self.tutesScore.text = scoreString
                                    self.tutesScore.textColor = scoreColor
                                    self.tutesValue.text = valueStringPercent
                                    self.tutesValue.textColor = valueColor
                                    break
                                case "cashflowDebt":
                                    self.cashFlowDebtScore.text = scoreString
                                    self.cashFlowDebtScore.textColor = scoreColor
                                    self.cashflowDebtValue.text = valueString
                                    self.cashflowDebtValue.textColor = valueColor
                                    break
                                case "dividendYield":
                                    self.dividendScore.text = scoreString
                                    self.dividendScore.textColor = scoreColor
                                    self.dividendValue.text = valueStringPercent
                                    self.dividendValue.textColor = valueColor
                                    break
                                default:
                                    break
                            }
                        }
                    }
                    self.scoreSnowflakeChart.setup(scores: scoresForChart)
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
