//
//  GeneralInfoViewController.swift
//  stonks
//
//  Created by Samuel Hobel on 8/20/19.
//  Copyright © 2019 Samuel Hobel. All rights reserved.
//

import UIKit
import FCAlertView
import SwiftSoup
import SafariServices

class PremiumViewController: UIViewController, StatsVC, ShadowButtonDelegate {
    
    @IBOutlet weak var contentView: UIView!
    
    //kavout
    @IBOutlet weak var kscoreDateLabel: UILabel!
    @IBOutlet weak var growthbar: CustomProgressView!
    @IBOutlet weak var momentumbar: CustomProgressView!
    @IBOutlet weak var valuebar: CustomProgressView!
    @IBOutlet weak var qualitybar: CustomProgressView!
    @IBOutlet weak var kavoutbar: CustomProgressView!
    @IBOutlet weak var overallRatingsView: UIView!
    @IBOutlet weak var overallPercent: UILabel!
    
    //brain 30 day sentiment
    @IBOutlet weak var brain30dateLabel: UILabel!
    @IBOutlet weak var brainSentimentNegative: UIProgressView!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var brainSentimentPositive: UIProgressView!
    @IBOutlet weak var brain30volumeLabel: UILabel!
    @IBOutlet weak var brain30sentLabel: UILabel!
    
    //bran 21 ml ranking
    @IBOutlet weak var brain21dateLabel: UILabel!
    @IBOutlet weak var brain21ratingsView: UIView!
    @IBOutlet weak var brain21Percent: UILabel!
    @IBOutlet weak var brain21ReturnLabel: UILabel!
    
    //brain language
    @IBOutlet weak var blDateLabel: UILabel!
    @IBOutlet weak var blSentimentNegative: CustomProgressView!
    @IBOutlet weak var blDivider: UIView!
    @IBOutlet weak var blSentimentPositive: CustomProgressView!
    @IBOutlet weak var blUncertain: CustomProgressView!
    @IBOutlet weak var blLitigious: CustomProgressView!
    @IBOutlet weak var blConstraining: CustomProgressView!
    @IBOutlet weak var blInteresting: CustomProgressView!
    
    //stocktwits sentiment
    @IBOutlet weak var sstDateLabel: UILabel!
    @IBOutlet weak var stSentimentNegative: CustomProgressView!
    @IBOutlet weak var stDivider: UIView!
    @IBOutlet weak var stSentimentPositive: CustomProgressView!
    @IBOutlet weak var stTotalScoreLabel: UILabel!
    @IBOutlet weak var stPositiveLabel: UILabel!
    @IBOutlet weak var stNegativeLabel: UILabel!
    
    //precision alpha
    @IBOutlet weak var paDateLabel: UILabel!
    @IBOutlet weak var paValueUp: UILabel!
    @IBOutlet weak var paValueDown: UILabel!
    @IBOutlet weak var paValueEmotion: UILabel!
    @IBOutlet weak var paValuePower: UILabel!
    @IBOutlet weak var paValueResist: UILabel!
    @IBOutlet weak var paValueNoise: UILabel!
    @IBOutlet weak var paValueTemp: UILabel!
    @IBOutlet weak var paValueFreeEnergy: UILabel!
    
    @IBOutlet weak var kavoutInfoView: UIView!
    @IBOutlet weak var sent30InfoView: UIView!
    @IBOutlet weak var stocktwitsInfoView: UIView!
    @IBOutlet weak var brain21InfoView: UIView!
    @IBOutlet weak var brainLanguageInfoView: UIView!
    @IBOutlet weak var precisionAlphaInfoView: UIView!
    
    @IBOutlet weak var kavoutUpdateButton: ShadowButtonView!
    @IBOutlet weak var day30SentimentUpdateButton: ShadowButtonView!
    @IBOutlet weak var day21ReturnUpdateButton: ShadowButtonView!
    @IBOutlet weak var languageUpdateButton: ShadowButtonView!
    @IBOutlet weak var stocktwitsUpdateButton: ShadowButtonView!
    @IBOutlet weak var precisionAlphaButton: ShadowButtonView!
    
    private var company:Company!
    private var isLoaded = false
    
    private var kscoreData:Kscore?
    private var brain30SentimentData:BrainSentiment?
    private var brainLanguageData:BrainLanguage?
    private var brain21RankingData:Brain21DayRanking?
    private var stocktwitsSentimentData:StocktwitsSentiment?
    private var precisionAlphaData:PrecisionAlphaDynamics?
    
    public var stockDetailsDelegate:StockDetailsVC!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                        
        self.kavoutUpdateButton.delegate = self
        self.day21ReturnUpdateButton.delegate = self
        self.day30SentimentUpdateButton.delegate = self
        self.languageUpdateButton.delegate = self
        self.stocktwitsUpdateButton.delegate = self
        self.precisionAlphaButton.delegate = self
        
        self.setupOveralRatingView(self.overallRatingsView)
        self.setupOveralRatingView(self.brain21ratingsView)
        
        self.setupSentimentBars(self.brainSentimentNegative, pvp: self.brainSentimentPositive, divider: self.divider)
        self.setupSentimentBars(self.blSentimentNegative, pvp: self.blSentimentPositive, divider: self.blDivider)
        self.setupSentimentBars(self.stSentimentNegative, pvp: self.stSentimentPositive, divider: self.stDivider)
        
        self.isLoaded = true
        self.company = Dataholder.selectedCompany!
        
        //gets the cost of the different premium packages
        NetworkManager.getMyRestApi().getPremiumPackages(completionHandler: handlePremiumPackages)
        
        //gets the saved premium data
        NetworkManager.getMyRestApi().getPremiumData(symbol: company.symbol, completionHandler: handlePremiumData)

    }
    
    private func setupOveralRatingView(_ view:UIView){
        view.layer.cornerRadius = view.frame.width/2.0
        view.layer.masksToBounds = true
        view.clipsToBounds = true
    }
    
    private func setupSentimentBars(_ pvn:UIProgressView, pvp:UIProgressView, divider:UIView) {
        pvn.transform = CGAffineTransform(scaleX: -1.0, y: 1.0);
        pvn.tintColor = Constants.darkPink
        pvp.tintColor = Constants.green
        divider.layer.cornerRadius = 2.0
    }
    
    public func shadowButtonTapped(_ premiumPackage:PremiumPackage?){
        if premiumPackage != nil {
            if premiumPackage!.credits ?? 0 > Dataholder.getCreditBalance() {
                self.showPurchaseController()
            } else {
                self.showInfoAlert(premiumPackage!)
            }
        } else {
            self.showPurchaseController()
        }
    }
    
    private func showPurchaseController(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let purchaseVC = storyboard.instantiateViewController(withIdentifier: "purchaseCreditsVC") as! PurchaseViewController
        self.present(purchaseVC, animated: true, completion: nil)
    }
    
    public func buyUpdateAction(_ premiumPackage:PremiumPackage){
        self.stockDetailsDelegate.hideLoader(false)
        NetworkManager.getMyRestApi().buyPremiumPackage(symbol: self.company.symbol, packageId: premiumPackage.id!) {
            premiumData, newCredits, error in
            if let error = error, let credits = newCredits {
                DispatchQueue.main.async {
                    self.stockDetailsDelegate.hideLoader(true)
                    self.showErrorAlert(error, credits: credits)
                }
                return
            }
            Dataholder.updateCreditBalance(newCredits ?? 0)

            if premiumPackage.id == Constants.premiumPackageIds.PREMIUM_KAVOUT_KSCORE {
                self.kscoreData = premiumData as? Kscore
            } else if premiumPackage.id == Constants.premiumPackageIds.PREMIUM_BRAIN_RANKING_21_DAYS {
                self.brain21RankingData = premiumData as? Brain21DayRanking
            } else if premiumPackage.id == Constants.premiumPackageIds.PREMIUM_BRAIN_SENTIMENT_30_DAYS {
                self.brain30SentimentData = premiumData as? BrainSentiment
            } else if premiumPackage.id == Constants.premiumPackageIds.PREMIUM_BRAIN_LANGUAGE_METRICS_ALL {
                self.brainLanguageData = premiumData as? BrainLanguage
            } else if premiumPackage.id == Constants.premiumPackageIds.STOCKTWITS_SENTIMENT {
                self.stocktwitsSentimentData = premiumData as? StocktwitsSentiment
            } else if premiumPackage.id == Constants.premiumPackageIds.PREMIUM_PRECISION_ALPHA_PRICE_DYNAMICS {
                self.precisionAlphaData = premiumData as? PrecisionAlphaDynamics
            }
            self.updateData()
        }
    }
    
    private func handlePremiumPackages(_ premiumPackages:[PremiumPackage]){
        DispatchQueue.main.async {
            for package in premiumPackages {
                var currentButton:ShadowButtonView?
                switch package.id {
                case Constants.premiumPackageIds.PREMIUM_BRAIN_LANGUAGE_METRICS_ALL:
                    currentButton = self.languageUpdateButton
                    break
                case Constants.premiumPackageIds.PREMIUM_BRAIN_RANKING_21_DAYS:
                    currentButton = self.day21ReturnUpdateButton
                    break
                case Constants.premiumPackageIds.PREMIUM_BRAIN_SENTIMENT_30_DAYS:
                    currentButton = self.day30SentimentUpdateButton
                    break
                case Constants.premiumPackageIds.PREMIUM_KAVOUT_KSCORE:
                    currentButton = self.kavoutUpdateButton
                    break
                case Constants.premiumPackageIds.STOCKTWITS_SENTIMENT:
                    currentButton = self.stocktwitsUpdateButton
                    break
                case Constants.premiumPackageIds.PREMIUM_PRECISION_ALPHA_PRICE_DYNAMICS:
                    currentButton = self.precisionAlphaButton
                    break
                case .none:
                    break
                case .some(_):
                    break
                }
                if currentButton != nil {
                    currentButton!.credits.text = String(package.credits!)
                    currentButton!.premiumPackage = package
                    currentButton!.bgColor = UIColor(red: 48.0/255.0, green: 203.0/255.0, blue: 141.0/255.0, alpha: 1.0)
                    currentButton!.shadColor = UIColor(red: 25.0/255.0, green: 105.0/255.0, blue: 75.0/255.0, alpha: 1.0).cgColor
                }
            }
        }
    }
    
    private func handlePremiumData(_ premiumData:[String:PremiumDataBase?]) {
        for (id, data):(String, PremiumDataBase?) in premiumData {
            if let data = data {
                switch id {
                case Constants.premiumPackageIds.PREMIUM_BRAIN_LANGUAGE_METRICS_ALL:
                    self.brainLanguageData = data as? BrainLanguage
                    break
                case Constants.premiumPackageIds.PREMIUM_KAVOUT_KSCORE:
                    self.kscoreData = data as? Kscore
                    break
                case Constants.premiumPackageIds.PREMIUM_BRAIN_RANKING_21_DAYS:
                    self.brain21RankingData = data as? Brain21DayRanking
                    break
                case Constants.premiumPackageIds.PREMIUM_BRAIN_SENTIMENT_30_DAYS:
                    self.brain30SentimentData = data as? BrainSentiment
                    break
                case Constants.premiumPackageIds.STOCKTWITS_SENTIMENT:
                    self.stocktwitsSentimentData = data as? StocktwitsSentiment
                    break
                case Constants.premiumPackageIds.PREMIUM_PRECISION_ALPHA_PRICE_DYNAMICS:
                    self.precisionAlphaData = data as? PrecisionAlphaDynamics
                    break
                default:
                    break
                }
            }
        }
        self.updateData()
    }
    
    func updateData() {
        self.company = Dataholder.selectedCompany!
        //TODO remove premium data from company object
        if (isLoaded) {
            DispatchQueue.main.async {
                var score:Float = 0
                var total:Float = 0
                if self.kscoreData != nil {
                    self.kavoutInfoView.isHidden = true
                } else {
                    self.kavoutInfoView.isHidden = false
                }
                if let gs = self.kscoreData?.growthScore {
                    self.growthbar.setProgress(Float(gs)/9, animated: true)
                    self.growthbar.tintColor = self.getTintColorForProgressValue(value: Float(gs)/9)
                    score += Float(gs)
                    total += 9
                }
                if let ms = self.kscoreData?.momentumScore {
                    self.momentumbar.setProgress(Float(ms)/9, animated: true)
                    self.momentumbar.tintColor = self.getTintColorForProgressValue(value: Float(ms)/9)
                    score += Float(ms)
                    total += 9
                }
                if let vs = self.kscoreData?.valueScore {
                    self.valuebar.setProgress(Float(vs)/9, animated: true)
                    self.valuebar.tintColor = self.getTintColorForProgressValue(value: Float(vs)/9)
                    score += Float(vs)
                    total += 9
                }
                if let qs = self.kscoreData?.qualityScore {
                    self.qualitybar.setProgress(Float(qs)/9, animated: true)
                    self.qualitybar.tintColor = self.getTintColorForProgressValue(value: Float(qs)/9)
                    score += Float(qs)
                    total += 9
                }
                if let ks = self.kscoreData?.kscore {
                    self.kavoutbar.setProgress(Float(ks)/9, animated: true)
                    self.kavoutbar.tintColor = self.getTintColorForProgressValue(value: Float(ks)/9)
                    score += Float(ks)
                    total += 9
                }
                if let ksid = self.kscoreData?.id {
                    self.kscoreDateLabel.text = ksid
                }
                let overallScore = score / total
                let backgroundColor = self.getTintColorForProgressValue(value: overallScore).withAlphaComponent(0.2)
                self.overallRatingsView.backgroundColor = backgroundColor
                self.overallPercent.text = String("\(String(format: "%.0f", Double(overallScore) * 100))%")
                self.overallPercent.textColor = self.getTintColorForProgressValue(value: overallScore)
                
                if let bsd = self.brain30SentimentData {
                    self.sent30InfoView.isHidden = true
                    if bsd.sentimentScore != nil {
                        if bsd.sentimentScore! > 0.0 {
                            self.brainSentimentPositive.setProgress(Float(bsd.sentimentScore!)*5.0, animated: true)
                        } else {
                            self.brainSentimentNegative.setProgress(Float(bsd.sentimentScore! * -1)*5.0, animated: true)
                        }
                    }
                    if bsd.id != nil {
                        self.brain30dateLabel.text = bsd.id
                    }
                    if bsd.sentimentScore != nil {
                        self.brain30sentLabel.text = String("\(bsd.volumeSentiment!)")
                    }
                    if bsd.volumeSentiment != nil {
                        self.brain30volumeLabel.text = String("\(bsd.volume!)")
                    }
                } else{
                    self.sent30InfoView.isHidden = false
                }
                
                if let brd = self.brain21RankingData {
                    self.brain21InfoView.isHidden = true
                    self.brain21dateLabel.text = brd.id
                    let backgroundColor = self.getTintColorForReturnValue(value: Float(brd.mlAlpha ?? 0.0)).withAlphaComponent(0.2)
                    self.brain21ratingsView.backgroundColor = backgroundColor
                    self.brain21Percent.text = String("\(String(format: "%.0f", Double(brd.mlAlpha ?? 0.0) * 100))%")
                    self.brain21Percent.textColor = self.getTintColorForReturnValue(value: Float(brd.mlAlpha ?? 0.0))
                    self.brain21ReturnLabel.text = "The predicted return over the next 21 days is " + String(format: "%.f", Double(brd.mlAlpha ?? 0.0) * 100) + "%"
                } else {
                    self.brain21InfoView.isHidden = false
                }
                
                if let bld = self.brainLanguageData {
                    self.brainLanguageInfoView.isHidden = true
                    self.blDateLabel.text = bld.id
                    if bld.sentiment != nil {
                        if bld.sentiment! > 0.0 {
                            self.blSentimentPositive.setProgress(Float(bld.sentiment!)*5.0, animated: true)
                        } else {
                            self.blSentimentNegative.setProgress(Float(bld.sentiment! * -1)*5.0, animated: true)
                        }
                    }
                    let su = bld.scoreUncertainty ?? 0.0
                    self.blUncertain.setProgress(Float(su), animated: true)
                    self.blUncertain.tintColor = self.getTintColorForProgressValue(value: Float(su))
                    let sl = bld.scoreLitigious ?? 0.0
                    self.blLitigious.setProgress(Float(sl), animated: true)
                    self.blLitigious.tintColor = self.getTintColorForProgressValue(value: Float(sl))
                    let si = bld.scoreInteresting ?? 0.0
                    self.blInteresting.setProgress(Float(si), animated: true)
                    self.blInteresting.tintColor = self.getTintColorForProgressValue(value: Float(si))
                    let sc = bld.scoreConstraining ?? 0.0
                    self.blConstraining.setProgress(Float(sc), animated: true)
                    self.blConstraining.tintColor = self.getTintColorForProgressValue(value: Float(sc))
                } else {
                    self.brainLanguageInfoView.isHidden = false
                }
                
                if let std = self.stocktwitsSentimentData {
                    self.stocktwitsInfoView.isHidden = true
                    self.sstDateLabel.text = std.id
                    if std.sentiment != nil {
                        if std.sentiment! > 0.0 {
                            self.stSentimentPositive.setProgress(Float(std.sentiment!)*5.0, animated: true)
                        } else {
                            self.stSentimentNegative.setProgress(Float(std.sentiment! * -1)*5.0, animated: true)
                        }
                    }
                    self.stTotalScoreLabel.text = String("\(std.totalScores ?? 0)")
                    self.stPositiveLabel.text = String("\(std.positive ?? 0.0)")
                    self.stNegativeLabel.text = String("\(std.negative ?? 0.0)")
                } else {
                    self.stocktwitsInfoView.isHidden = false
                }
                
                if let pa = self.precisionAlphaData {
                    self.precisionAlphaInfoView.isHidden = true
                    self.paDateLabel.text = pa.id
                    self.paValueUp.text = String("\(pa.probabilityUp ?? 0.0)")
                    self.paValueDown.text = String("\(pa.probabilityDown ?? 0.0)")
                    self.paValueEmotion.text = String("\(pa.marketEmotion ?? 0.0)")
                    self.paValueNoise.text = String("\(pa.marketNoise ?? 0.0)")
                    self.paValueResist.text = String("\(pa.marketResistance ?? 0.0)")
                    self.paValueTemp.text = String("\(pa.marketTemperature ?? 0.0)")
                    self.paValueFreeEnergy.text = String("\(pa.marketFreeEnergy ?? 0.0)")
                    self.paValuePower.text = String("\(pa.marketPower ?? 0.0)")

                }
            }
        }
        self.stockDetailsDelegate.hideLoader(true)
    }
    
    func showInfoAlert(_ package:PremiumPackage){
        let message = "You are about to use " + String(package.credits!) + " credits to get " + package.name! + " data for " + company.fullName + ". If you have already received this data recently, new data might not meaningfully differ from what you already have, depending on market conditions."
        let alert = FCAlertView()
        alert.doneActionBlock {
            self.buyUpdateAction(package)
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
    
    func showErrorAlert(_ error:String, credits:Int){
        let message = String("\(error) No credits were used and your balance remains at \(credits).")
        let alert = FCAlertView()
        alert.colorScheme = Constants.darkPink
        alert.dismissOnOutsideTouch = true
        alert.detachButtons = true
        alert.showAlert(inView: self,
                        withTitle: "Error",
                        withSubtitle: message,
                        withCustomImage: UIImage(systemName: "exclamationmark.triangle.fill"),
                        withDoneButtonTitle: "Ok", andButtons: nil)
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
    
    func getTintColorForReturnValue(value:Float) -> UIColor {
        if value > 0.05 {
            return Constants.green
        } else if value > 0.0 {
            return Constants.yellow
        } else {
            return Constants.darkPink
        }
    }
    
    func getContentHeight() -> CGFloat {
        if isLoaded {
            return self.contentView.bounds.height + 50
        }
        return 0.0
    }
    
    func creditBalanceUpdated() {
        return
    }
    
    @IBAction func openLink(_ sender: Any) {
        if let button = sender as? UIButton, let url = URL(string: button.titleLabel?.text ?? "https://google.com") {
            UIApplication.shared.open(url)
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
