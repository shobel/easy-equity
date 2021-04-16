//
//  GeneralInfoViewController.swift
//  stonks
//
//  Created by Samuel Hobel on 8/20/19.
//  Copyright © 2019 Samuel Hobel. All rights reserved.
//

import UIKit

class PremiumViewController: UIViewController, StatsVC {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var growthbar: CustomProgressView!
    @IBOutlet weak var momentumbar: CustomProgressView!
    @IBOutlet weak var valuebar: CustomProgressView!
    @IBOutlet weak var qualitybar: CustomProgressView!
    @IBOutlet weak var kavoutbar: CustomProgressView!
    
    @IBOutlet weak var overallRatingsView: UIView!
    @IBOutlet weak var overallPercent: UILabel!
    
    @IBOutlet weak var brainSentimentNegative: UIProgressView!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var brainSentimentPositive: UIProgressView!
    
    @IBOutlet weak var kavoutInfoView: UIView!
    @IBOutlet weak var sent30InfoView: UIView!
    
    private var company:Company!
    private var isLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.overallRatingsView.layer.cornerRadius = self.overallRatingsView.frame.width/1.8
        self.overallRatingsView.layer.masksToBounds = true
        self.overallRatingsView.clipsToBounds = true
        
        self.brainSentimentNegative.transform = CGAffineTransform(scaleX: -1.0, y: 1.0);
        self.brainSentimentNegative.tintColor = Constants.darkPink
        self.brainSentimentPositive.tintColor = Constants.green
        self.divider.layer.cornerRadius = 2.0

        self.isLoaded = true
        self.company = Dataholder.selectedCompany!
        
        NetworkManager.getMyRestApi().getPremiumData(symbol: company.symbol, completionHandler: handlePremiumData)
 
//        self.valuebar.tintColor = self.getTintColorForProgressValue(value: Float(0.2))
//        self.growthbar.tintColor = self.getTintColorForProgressValue(value: Float(0.7))
//        self.qualitybar.tintColor = self.getTintColorForProgressValue(value: Float(0.8))
//        self.kavoutbar.tintColor = self.getTintColorForProgressValue(value: Float(0.6))
//        self.momentumbar.tintColor = self.getTintColorForProgressValue(value: Float(0.5))
    }
    
    private func handlePremiumData(premiumStockInfo:PremiumStockInfo?, kscores: Kscore?, brainSentiment: BrainSentiment?) {
        if (premiumStockInfo == nil){

        } else {
            if (kscores != nil){
                self.company.kscores = kscores
            }
            if (brainSentiment != nil){
                self.company.brainSentiment = brainSentiment
            }
            self.updateData()
        }
    }
    
    func updateData() {
        self.company = Dataholder.selectedCompany!
        if (isLoaded) {
            DispatchQueue.main.async {
                var score:Float = 0
                var total:Float = 0
                if let x = self.company.kscores?.growthScore {
                    self.growthbar.setProgress(Float(x)/9, animated: true)
                    self.growthbar.tintColor = self.getTintColorForProgressValue(value: Float(x)/9)
                    score += Float(x)
                    total += 9
                }
                if let x = self.company.kscores?.momentumScore {
                    self.momentumbar.setProgress(Float(x)/9, animated: true)
                    self.momentumbar.tintColor = self.getTintColorForProgressValue(value: Float(x)/9)
                    score += Float(x)
                    total += 9
                }
                if let x = self.company.kscores?.valueScore {
                    self.valuebar.setProgress(Float(x)/9, animated: true)
                    self.valuebar.tintColor = self.getTintColorForProgressValue(value: Float(x)/9)
                    score += Float(x)
                    total += 9
                }
                if let x = self.company.kscores?.qualityScore {
                    self.qualitybar.setProgress(Float(x)/9, animated: true)
                    self.qualitybar.tintColor = self.getTintColorForProgressValue(value: Float(x)/9)
                    score += Float(x)
                    total += 9
                }
                if let x = self.company.kscores?.kscore {
                    self.kavoutbar.setProgress(Float(x)/9, animated: true)
                    self.kavoutbar.tintColor = self.getTintColorForProgressValue(value: Float(x)/9)
                    score += Float(x)
                    total += 9
                }
                
                let overallScore = score / total
                let backgroundColor = self.getTintColorForProgressValue(value: overallScore).withAlphaComponent(0.2)
                self.overallRatingsView.backgroundColor = backgroundColor
                self.overallPercent.text = String("\(String(format: "%.0f", Double(overallScore) * 100))%")
                self.overallPercent.textColor = self.getTintColorForProgressValue(value: overallScore)
                
                if let x = self.company.brainSentiment {
                    if x.sentimentScore! > 0.0 {
                        self.brainSentimentPositive.setProgress(Float(x.sentimentScore!), animated: true)
                    } else {
                        self.brainSentimentNegative.setProgress(Float(x.sentimentScore! * -1), animated: true)
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
