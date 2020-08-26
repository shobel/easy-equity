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
    
    @IBOutlet weak var numAnalysts: UILabel!
    @IBOutlet weak var updateDate: UILabel!
    
    @IBOutlet weak var overallRatingsView: UIView!
    @IBOutlet weak var overallPercent: UILabel!
    @IBOutlet weak var overallLabel: UILabel!
    
    @IBOutlet weak var priceTargetContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var modeControl: UISegmentedControl!
    @IBOutlet weak var accuracyLabel: UILabel!
    @IBOutlet weak var avgReturnLabel: UILabel!
    @IBOutlet weak var topAnalystSuccessRateView: CircularProgressView!
    @IBOutlet weak var avgReturnView: CircularProgressView!

    @IBOutlet weak var priceTargetChartTopConstraint: NSLayoutConstraint!
    
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
        self.isLoaded = true
        self.overallRatingsView.layer.cornerRadius = self.overallRatingsView.frame.width/2
        self.overallRatingsView.layer.masksToBounds = true
        self.overallRatingsView.clipsToBounds = true
        
        self.accuracyLabel.alpha = 0
        self.avgReturnLabel.alpha = 0
        self.topAnalystSuccessRateView.alpha = 0
        self.avgReturnView.alpha = 0
        
        self.topAnalystSuccessRateView.setProgress(0.0)
        self.avgReturnView.setProgress(0.0)
        
        self.modeControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        
        updateData();
    }
    
    func updateData() {
        self.company = Dataholder.selectedCompany!
        if (isLoaded) {
            self.ratingsChartView.setup(company: self.company, predictionsDelegate: self)
            if let x = self.company.priceTarget?.updatedDate {
                self.updateDate.text = NumberFormatter.formatDate(x)
            }
            if let x = self.company.recommendations?.ratingScaleMark {
                let overallPercentVal = (1 - ((x-1) / 2))*100
                self.overallPercent.text = String("\(String(format: "%.0f", overallPercentVal))%")
                var colorIndex:Int = 0
                var overallText = ""
                if x <= 1.25 {
                    overallText = "Strong Buy"
                    colorIndex = 0
                } else if x <= 1.75 {
                    overallText = "Buy"
                    colorIndex = 1
                } else if x <= 2.25 {
                    overallText = "Hold"
                    colorIndex = 2
                } else if x <= 2.75 {
                    overallText = "Sell"
                    colorIndex = 3
                } else if x <= 3 {
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
            
            if let x = self.company.priceTarget?.numberOfAnalysts {
                var n = x
                if self.allMode {
                    if hasTipranksAnalysts {
                        n = x + (self.company.priceTargetTopAnalysts?.numAnalysts)!
                    }
                } else if !self.allMode && hasTipranksAnalysts {
                    n = (self.company.priceTargetTopAnalysts?.numAnalysts)!
                }
                let analystString = n > 1 ? "analysts" : "analyst"
                self.numAnalysts.text = String("\(n) \(analystString)")
            }
            self.priceTargetChartView.setup(company: self.company, predictionsDelegate: self, allMode: self.allMode)
        }
    }
    
    func getTintColorForReturnValue(value:Float) -> UIColor {
        if value > 0.3 {
            return Constants.green
        } else if value > 0.1 {
            return Constants.yellow
        } else {
            return Constants.darkPink
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
    
    func noTopAnalysts(){
        modeControl.isHidden = true
        accuracyLabel.isHidden = true
        avgReturnLabel.isHidden = true
        topAnalystSuccessRateView.isHidden = true
        avgReturnView.isHidden = true
        priceTargetChartTopConstraint.constant = 10
        self.priceTargetContainerHeight.constant = 250
        self.view.layoutIfNeeded()
    }
    
    @IBAction func changeMode(_ sender: Any) {
        self.allMode = !self.allMode
        self.updateData()
        UIView.animate(withDuration: 0.2) {
            if self.allMode {
                self.accuracyLabel.alpha = 0
                self.avgReturnLabel.alpha = 0
                self.topAnalystSuccessRateView.alpha = 0
                self.avgReturnView.alpha = 0
            
                self.topAnalystSuccessRateView.setProgress(CGFloat(0.0))
                self.avgReturnView.setProgressAndLabel(CGFloat(0.0), label: String(Int((self.avgAnalystReturn*100).rounded())) + "%")

                self.priceTargetChartTopConstraint.constant = 60
                self.priceTargetContainerHeight.constant = 300
            } else {
                self.accuracyLabel.alpha = 1
                self.avgReturnLabel.alpha = 1
                self.topAnalystSuccessRateView.alpha = 1
                self.avgReturnView.alpha = 1
            
                self.topAnalystSuccessRateView.setProgress(CGFloat(self.avgAnalystSuccessRate))
                self.avgReturnView.setProgressAndLabel(CGFloat(self.avgAnalystReturn/0.3), label: String(Int((self.avgAnalystReturn*100).rounded())) + "%")
            
                self.priceTargetChartTopConstraint.constant = 140
                self.priceTargetContainerHeight.constant = 360
            }
            if let p = self.parent?.parent?.parent as? StockDetailsVC {
                p.adjustContentHeight(vc: self)
            }
            self.view.layoutIfNeeded()
        }
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
