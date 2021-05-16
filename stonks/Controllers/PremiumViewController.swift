//
//  GeneralInfoViewController.swift
//  stonks
//
//  Created by Samuel Hobel on 8/20/19.
//  Copyright © 2019 Samuel Hobel. All rights reserved.
//

import UIKit
import FCAlertView

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
    
    @IBOutlet weak var kavoutUpdateButton: ShadowButtonView!
    @IBOutlet weak var day30SentimentUpdateButton: ShadowButtonView!
    @IBOutlet weak var day21ReturnUpdateButton: ShadowButtonView!
    @IBOutlet weak var languageUpdateButton: ShadowButtonView!
    @IBOutlet weak var stocktwitsUpdateButton: ShadowButtonView!
    
    private var company:Company!
    private var isLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.kavoutUpdateButton.delegate = self
        self.day21ReturnUpdateButton.delegate = self
        self.day30SentimentUpdateButton.delegate = self
        self.languageUpdateButton.delegate = self
        self.stocktwitsUpdateButton.delegate = self
        
        self.overallRatingsView.layer.cornerRadius = self.overallRatingsView.frame.width/1.8
        self.overallRatingsView.layer.masksToBounds = true
        self.overallRatingsView.clipsToBounds = true
        
        self.brainSentimentNegative.transform = CGAffineTransform(scaleX: -1.0, y: 1.0);
        self.brainSentimentNegative.tintColor = Constants.darkPink
        self.brainSentimentPositive.tintColor = Constants.green
        self.divider.layer.cornerRadius = 2.0

        self.isLoaded = true
        self.company = Dataholder.selectedCompany!
        
        //gets the cost of the different premium packages
        NetworkManager.getMyRestApi().getPremiumPackages(completionHandler: handlePremiumPackages)
        
        //
        self.handlePremiumData(kscores: nil, brainSentiment: nil, brain21Ranking: nil, brainLanguage: nil, stocktwitsSentiment: nil)
        //NetworkManager.getMyRestApi().getPremiumData(symbol: company.symbol, completionHandler: handlePremiumData)

    }
    
    public func buyUpdateButtonTapped(_ premiumPackage:PremiumPackage?){
        if premiumPackage != nil {
            self.showInfoAlert(premiumPackage!)
        }
    }
    
    private func handlePremiumPackages(_ premiumPackages:[PremiumPackage]){
        DispatchQueue.main.async {
            for package in premiumPackages {
                var currentButton:ShadowButtonView?
                switch package.id {
                    case "PREMIUM_BRAIN_LANGUAGE_METRICS_ALL":
                        currentButton = self.languageUpdateButton
                        break
                    case "PREMIUM_BRAIN_RANKING_21_DAYS":
                        currentButton = self.day21ReturnUpdateButton
                        break
                    case "PREMIUM_BRAIN_SENTIMENT_30_DAYS":
                        currentButton = self.day30SentimentUpdateButton
                        break
                    case "PREMIUM_KAVOUT_KSCORE":
                        currentButton = self.kavoutUpdateButton
                        break
                    case "STOCKTWITS_SENTIMENT":
                        currentButton = self.stocktwitsUpdateButton
                        break
                    case .none:
                        break
                    case .some(_):
                        break
                    
                }
                if currentButton != nil {
                    currentButton!.credits.text = String(package.credits!)
                    currentButton!.premiumPackage = package
                }
            }
        }
    }
    
    private func handlePremiumData(kscores: Kscore?, brainSentiment: BrainSentiment?, brain21Ranking:Brain21DayRanking?, brainLanguage:BrainLanguage?, stocktwitsSentiment:StocktwitsSentiment?) {
        if kscores != nil {
            self.company.kscores = kscores
        }
        if brainSentiment != nil {
            self.company.brainSentiment = brainSentiment
        }
        if (brain21Ranking != nil){

        }
        if (brainLanguage != nil){

        }
        if stocktwitsSentiment != nil {

        }
        self.updateData()
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
    
    func showInfoAlert(_ package:PremiumPackage){
        let message = "You are about to use " + String(package.credits!) + " credits to get " + package.name! + " data for " + company.fullName + ". If you have already received this data recently, new data might not meaningfully differ from what you already have, depending on market conditions."
        let alert = FCAlertView()
        alert.doneActionBlock {
            print("use")
        }
        alert.colorScheme = Constants.green
        alert.dismissOnOutsideTouch = true
        alert.detachButtons = true
        alert.showAlert(inView: self,
                        withTitle: "Premium Data",
                        withSubtitle: message,
                        withCustomImage: UIImage(named: "coin_bw.png"),
                        withDoneButtonTitle: "Use",
                        andButtons: ["Cancel"])
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
