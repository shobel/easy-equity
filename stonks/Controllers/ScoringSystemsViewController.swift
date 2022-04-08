//
//  ScoringSystemsViewController.swift
//  stonks
//
//  Created by Samuel Hobel on 3/11/22.
//  Copyright © 2022 Samuel Hobel. All rights reserved.
//

import UIKit
import FCAlertView

class ScoringSystemsViewController: UIViewController, ShadowButtonDelegate {

    @IBOutlet weak var purchaseAnalystsButton: ShadowButtonView!
    @IBOutlet weak var topAnalystsGoButton: UIButton!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var daysRemaining: UILabel!
    @IBOutlet weak var creditBalanceButton: ShadowButtonView!
    
    private var analystPackage:PremiumPackage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.purchaseAnalystsButton.delegate = self
        Dataholder.subscribeForCreditBalanceUpdates(self)
        
        self.creditBalanceButton.credits.text = String("\(Dataholder.getCreditBalance())")
        self.creditBalanceButton.delegate = self
        self.creditBalanceButton.bgColor = Constants.orange
        self.creditBalanceButton.shadColor = UIColor(red: 100.0/255.0, green: 60.0/255.0, blue: 25.0/255.0, alpha: 1.0).cgColor
        
        self.loader.isHidden = false
        self.purchaseAnalystsButton.isHidden = true
        self.daysRemaining.isHidden = true

        NetworkManager.getMyRestApi().getAnalystsPremiumPackage(completionHandler: handlePackage)
    }
    
    func handlePackage(_ p: PremiumPackage?){
        DispatchQueue.main.async {
            self.analystPackage = p
            if self.analystPackage != nil {
                self.purchaseAnalystsButton.premiumPackage = self.analystPackage
                self.purchaseAnalystsButton.credits.text = String(self.analystPackage!.credits ?? 0)
                NetworkManager.getMyRestApi().getTopAnalystsSubscription(completionHandler: self.handleCheckSub)
            } else {
                self.purchaseAnalystsButton.isHidden = true
                self.loader.isHidden = true
            }
        }
    }
    
    func handleCheckSub(_ date:Int?) {
        DispatchQueue.main.async {
            if date != nil {
                let diff = Calendar.current.dateComponents([.day], from: Date(timeIntervalSince1970: TimeInterval(date!/1000)), to: Date()).day
                let daysLeft = 30 - (diff ?? 30)
                self.daysRemaining.text = String("enabled for \(daysLeft) more days")
                self.daysRemaining.isHidden = false
                self.purchaseAnalystsButton.isHidden = true
                self.topAnalystsGoButton.isHidden = false
            } else {
                self.purchaseAnalystsButton.isHidden = false
                self.topAnalystsGoButton.isHidden = true
                self.daysRemaining.isHidden = true
            }
            self.loader.isHidden = true
        }
    }
    
    
    //response to subscribing
    func handleSub(_ timesStamp:Int?, credits:Int?, error:String?) {
        if error != nil {
            self.showErrorAlert(error ?? "", credits: credits ?? 0)
        } else {
            Dataholder.updateCreditBalance(credits ?? Dataholder.getCreditBalance())
            NetworkManager.getMyRestApi().getTopAnalystsSubscription(completionHandler: self.handleCheckSub)
        }
        DispatchQueue.main.async {
            self.loader.isHidden = true
        }
    }
    
    func shadowButtonTapped(_ premiumPackage: PremiumPackage?) {
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
    
    func buyUpdateAction(_ package:PremiumPackage){
        DispatchQueue.main.async {
            self.loader.isHidden = false
        }
        NetworkManager.getMyRestApi().subscribeTopAnalysts(completionHandler: handleSub)
    }
    
    func creditBalanceUpdated() {
        DispatchQueue.main.async {
            self.creditBalanceButton.credits.text = String("\(Dataholder.getCreditBalance())")
        }
    }
    
    func showInfoAlert(_ package:PremiumPackage){
        let message = "You are about to use " + String(package.credits!) + " credits to enable the " + package.name! + ". Once enabled, you will have access to regularly updated analyst data for 30 days."
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
