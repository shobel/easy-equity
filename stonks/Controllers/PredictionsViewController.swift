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
    @IBOutlet weak var priceTargetsOverTimeChartView: PriceTargetsOverTimeChart!
    
    @IBOutlet weak var numAnalysts: UILabel!
    @IBOutlet weak var updateDate: UILabel!
    
    @IBOutlet weak var overallRatingsView: UIView!
    @IBOutlet weak var overallPercent: UILabel!
    @IBOutlet weak var overallLabel: UILabel!
    
    @IBOutlet weak var modeControl: UISegmentedControl!
    @IBOutlet weak var accuracyLabel: UILabel!
    @IBOutlet weak var avgReturnLabel: UILabel!
    @IBOutlet weak var topAnalystSuccessRateView: CircularProgressView!
    @IBOutlet weak var avgReturnView: CircularProgressView!

    @IBOutlet weak var priceTargetChartTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var priceTargetLabelTop: NSLayoutConstraint!
    @IBOutlet weak var analystButtonView: UIView!
    
    @IBOutlet weak var noPriceTargetsOverTime: UILabel!
    
    private var company:Company!
    private var isLoaded = false
    
    private var allMode:Bool = true
    private var avgAnalystReturn:Double = 0.0
    private var avgAnalystSuccessRate:Double = 0.0
    
    private var ratingBackgroundColors = [
        UIColor(red: 70.0/255.0, green: 180.0/255.0, blue: 88.0/255.0, alpha: 1),
        UIColor(red: 164.0/255.0, green: 217.0/255.0, blue: 51.0/255.0, alpha: 1),
        UIColor(red: 206.0/255.0, green: 194.0/255.0, blue: 46.0/255.0, alpha: 1),
        UIColor(red: 238.0/255.0, green: 143.0/255.0, blue: 29.0/255.0, alpha: 1),
        Constants.darkPink
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.company = Dataholder.selectedCompany!
        self.overallRatingsView.layer.cornerRadius = self.overallRatingsView.frame.width/2
        self.overallRatingsView.layer.masksToBounds = true
        self.overallRatingsView.clipsToBounds = true
        
        self.analystButtonView.layer.borderWidth = 1.0
        self.analystButtonView.layer.borderColor = Constants.lightGrey.cgColor
        self.analystButtonView.layer.cornerRadius = 5.0
        self.analystButtonView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        self.analystButtonView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.analystButtonView.layer.shadowOpacity = 1.0
        self.analystButtonView.layer.shadowRadius = 0.0
        self.analystButtonView.layer.masksToBounds = false
        
        self.accuracyLabel.alpha = 0
        self.avgReturnLabel.alpha = 0
        self.topAnalystSuccessRateView.alpha = 0
        self.avgReturnView.alpha = 0
        
        self.topAnalystSuccessRateView.setProgress(0.0)
        self.avgReturnView.setProgress(0.0)
        
        self.modeControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        
    }
    
    func setData(){
        self.ratingsChartView.setup(company: self.company, predictionsDelegate: self, allMode: self.allMode)
        if let x = self.company.priceTarget?.updatedDate {
            self.updateDate.text = NumberFormatter.formatDate(x)
        }
        var hasTipranksAnalysts:Bool = false
        if let x = self.company.priceTargetTopAnalysts {
            hasTipranksAnalysts = true
            let sr = x.avgAnalystSuccessRate!
            self.avgAnalystSuccessRate = sr
            self.topAnalystSuccessRateView.setProgress(CGFloat(sr))
            self.topAnalystSuccessRateView.setProgressColor(self.getTintColorForProgressValue(value: Float(sr)))

            let r = x.avgAnalystReturn!
            self.avgAnalystReturn = r
            self.avgReturnView.setProgressAndLabel(CGFloat(r/0.3), label: String(Int((r*100).rounded())) + "%")
            self.avgReturnView.setProgressColor(self.getTintColorForReturnValue(value: Float(r)))
        }
        if !hasTipranksAnalysts {
            self.noTopAnalysts()
        }
        
        var numAnalysts = 0
        if self.allMode {
            if let x = self.company.priceTarget?.numberOfAnalysts {
                numAnalysts += x
            }
            if hasTipranksAnalysts {
                numAnalysts += self.company.priceTargetTopAnalysts?.numAnalysts ?? 0
            }
            if let y = self.company.tipranksAllAnalysts {
                numAnalysts += y.count
            }
        } else if !self.allMode && hasTipranksAnalysts {
            numAnalysts += self.company.priceTargetTopAnalysts?.numAnalysts ?? 0
        }
        let analystString = numAnalysts > 1 ? "analysts" : "analyst"
        self.numAnalysts.text = String("\(numAnalysts) \(analystString)")
        
        self.priceTargetChartView.setup(company: self.company, predictionsDelegate: self, allMode: self.allMode)
        
        if self.company.priceTargetsOverTime != nil && self.company.priceTargetsOverTime!.count > 0 {
            self.priceTargetsOverTimeChartView.setup(company: self.company, allMode: self.allMode)
            self.priceTargetsOverTimeChartView.isHidden = false
            self.noPriceTargetsOverTime.isHidden = true
        } else {
            self.noPriceTargetsOverTime.isHidden = false
            self.priceTargetsOverTimeChartView.isHidden = true
        }

        self.isLoaded = true
        if let p = self.parent?.parent?.parent as? StockDetailsVC {
            p.adjustContentHeight(vc: self)
            p.hideLoader(true)
        }
    }
    
    func updateData() {
        if (!isLoaded) {
            if let p = self.parent?.parent?.parent as? StockDetailsVC {
                p.hideLoader(false)
            }
            NetworkManager.getMyRestApi().getFourthTabData(symbol: self.company.symbol, completionHandler: handlePredictions)
        }
    }
    
    func handlePredictions(priceTarget: PriceTarget, recommendations: Recommendations, priceTargetTopAnalysts: PriceTargetTopAnalysts?, allTipranksAnalystsForStock: [ExpertAndRatingForStock], priceTargetsOverTime: [SimpleTimeAndPrice], bestPriceTargetsOverTime: [SimpleTimeAndPrice]){
        self.company.priceTargetTopAnalysts = priceTargetTopAnalysts
        self.company.tipranksAllAnalysts = allTipranksAnalystsForStock
        self.company.priceTargetsOverTime = priceTargetsOverTime
        self.company.bestPriceTargetsOverTime = bestPriceTargetsOverTime
        self.company.priceTarget = priceTarget
        self.company.recommendations = recommendations
        DispatchQueue.main.async {
            self.setData()
        }
    }
    
    public func setOverallRecommendationScore(_ score:Double) {
        self.overallPercent.text = String("\(String(format: "%.0f", score*100.0))%")
        var colorIndex:Int = 0
        var overallText = ""
        if score >= 0.80 {
            overallText = "Strong Buy"
            colorIndex = 0
        } else if score >= 0.60 {
            overallText = "Buy"
            colorIndex = 1
        } else if score >= 0.40 {
            overallText = "Hold"
            colorIndex = 2
        } else if score >= 0.20 {
            overallText = "Sell"
            colorIndex = 3
        } else {
            overallText = "Strong Sell"
            colorIndex = 4
        }
        let labelColor:UIColor = self.ratingBackgroundColors[colorIndex]
        let backgroundColor = labelColor.withAlphaComponent(0.2)
        overallRatingsView.backgroundColor = backgroundColor
        overallLabel.textColor = labelColor
        overallPercent.textColor = labelColor
        overallLabel.text = overallText
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
    
    func getContentHeight() -> CGFloat {
        return self.contentView.bounds.height
    }
    
    func noTopAnalysts(){
        modeControl.isHidden = true
        accuracyLabel.isHidden = true
        avgReturnLabel.isHidden = true
        topAnalystSuccessRateView.isHidden = true
        avgReturnView.isHidden = true
        priceTargetChartTopConstraint.constant = 15
        priceTargetLabelTop.constant = 15
        self.view.layoutIfNeeded()
    }
    
    @IBAction func changeMode(_ sender: Any) {
        self.allMode = !self.allMode
        self.updateData()
        UIView.animate(withDuration: 0.2) { [self] in
            if self.allMode {
                self.accuracyLabel.alpha = 0
                self.avgReturnLabel.alpha = 0
                self.topAnalystSuccessRateView.alpha = 0
                self.avgReturnView.alpha = 0
            
                self.topAnalystSuccessRateView.setProgress(CGFloat(0.0))
                self.avgReturnView.setProgressAndLabel(CGFloat(0.0), label: String(Int((self.avgAnalystReturn*100).rounded())) + "%")

                self.priceTargetChartTopConstraint.constant = 10
            } else {
                self.accuracyLabel.alpha = 1
                self.avgReturnLabel.alpha = 1
                self.topAnalystSuccessRateView.alpha = 1
                self.avgReturnView.alpha = 1
            
                self.topAnalystSuccessRateView.setProgress(CGFloat(self.avgAnalystSuccessRate))
                self.avgReturnView.setProgressAndLabel(CGFloat(self.avgAnalystReturn/0.3), label: String(Int((self.avgAnalystReturn*100).rounded())) + "%")
            
                self.priceTargetChartTopConstraint.constant = 110
            }
            self.setData()
            if let p = self.parent?.parent?.parent as? StockDetailsVC {
                p.adjustContentHeight(vc: self)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? ExpertsViewController {
            let topExperts = self.company.priceTargetTopAnalysts?.expertRatings ?? []
            let otherExperts = self.company.tipranksAllAnalysts ?? []
            var expertDic:[String:ExpertAndRatingForStock] = [:]
            for expert in topExperts {
                if expert.name != nil {
                    let name = expert.name!.trimmingCharacters(in: .whitespaces)
                    if expertDic[name] == nil {
                        expertDic[name] = expert
                    }
                }
            }
            for expert in otherExperts {
                if expert.name != nil {
                    let name = expert.name!.trimmingCharacters(in: .whitespaces)
                    if expertDic[name] == nil {
                        expertDic[name] = expert
                    }
                }
            }
            dest.experts = Array(expertDic.values)
            
            dest.latestPrice = self.company.quote?.latestPrice ?? 0.0
            dest.symbol = self.company.symbol
            dest.companyName = self.company.fullName
            dest.companyLogo = self.company.generalInfo?.logo ?? ""
        }
     }
     
    
}
