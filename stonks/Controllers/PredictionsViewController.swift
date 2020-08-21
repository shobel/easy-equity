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
    
    @IBOutlet weak var priceTargetContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var modeControl: UISegmentedControl!
    @IBOutlet weak var accuracyLabel: UILabel!
    @IBOutlet weak var avgReturnLabel: UILabel!
    @IBOutlet weak var breaker: UIView!
    @IBOutlet weak var topAnalystSuccessRateView: CircularProgressView!
    @IBOutlet weak var avgReturnView: CircularProgressView!
    @IBOutlet weak var targetsStackTopConstraint: NSLayoutConstraint!
    
    private var company:Company!
    private var isLoaded = false
    
    private var allMode:Bool = true
    
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
        self.topAnalystSuccessRateView.setProgress(0.0)
        self.avgReturnView.setProgress(0.0)
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
            if let x = self.company.priceTargetTopAnalysts {
                if let y = x.avgAnalystSuccessRate {
                    self.topAnalystSuccessRateView.setProgress(CGFloat(y))
                    self.topAnalystSuccessRateView.setProgressColor(self.getTintColorForProgressValue(value: Float(y)))
                }
                if let y = x.avgAnalystReturn {
                    self.avgReturnView.setProgressAndLabel(CGFloat(y/0.3), label: String(Int((y*100).rounded())) + "%")
                    self.avgReturnView.setProgressColor(self.getTintColorForReturnValue(value: Float(y)))
                }
            }
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
        breaker.isHidden = true
        topAnalystSuccessRateView.isHidden = true
        avgReturnView.isHidden = true
        targetsStackTopConstraint.constant = 10
        self.view.layoutIfNeeded()
    }
    
    @IBAction func changeMode(_ sender: Any) {
        self.allMode = !self.allMode
        if self.allMode {
            accuracyLabel.isHidden = true
            avgReturnLabel.isHidden = true
            breaker.isHidden = true
            topAnalystSuccessRateView.isHidden = true
            avgReturnView.isHidden = true
            targetsStackTopConstraint.constant = 10
            priceTargetContainerHeight.constant = 320
        } else {
            accuracyLabel.isHidden = false
            avgReturnLabel.isHidden = false
            breaker.isHidden = false
            topAnalystSuccessRateView.isHidden = false
            avgReturnView.isHidden = false
            targetsStackTopConstraint.constant = 125
            priceTargetContainerHeight.constant = 400
        }
        self.view.layoutSubviews()
        self.view.layoutIfNeeded()
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
