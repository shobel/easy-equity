//
//  SettingsViewController.swift
//  stonks
//
//  Created by Samuel Hobel on 3/22/22.
//  Copyright © 2022 Samuel Hobel. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var userCustomized: UISwitch!
    @IBOutlet weak var analystRecs: UISwitch!
    @IBOutlet weak var avgUpside: UISwitch!
    @IBOutlet weak var topAnalysts: UISwitch!
    @IBOutlet weak var kavout: UISwitch!
    @IBOutlet weak var brain30sent: UISwitch!
    @IBOutlet weak var brain21return: UISwitch!
    @IBOutlet weak var stocktwits: UISwitch!
    @IBOutlet weak var paProbUp: UISwitch!
    
    var premiumPackages:[PremiumPackage] = []
    var premiumData:[PremiumDataBase] = []
    var allSwitches:[UISwitch] = []
    var packageIdToSwitch:[String:UISwitch] = [:]
    var selectedScore:String = ""
    var changeMade:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.allSwitches.append(userCustomized)
        self.allSwitches.append(analystRecs)
        self.allSwitches.append(avgUpside)
        self.allSwitches.append(topAnalysts)
        self.allSwitches.append(kavout)
        self.allSwitches.append(brain30sent)
        self.allSwitches.append(brain21return)
        self.allSwitches.append(stocktwits)
        self.allSwitches.append(paProbUp)
        
        self.packageIdToSwitch["USER_CUSTOMIZED"] = self.userCustomized
        self.packageIdToSwitch["ANALYST_RECOMMENDATIONS"] = self.analystRecs
        self.packageIdToSwitch["ANALYST_PRICE_TARGET_UPSIDE"] = self.avgUpside
        
        self.loader.isHidden = false
        //gets the cost of the different premium packages
        NetworkManager.getMyRestApi().getPremiumPackages(completionHandler: handlePremiumPackages)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.changeMade = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if changeMade {
            Dataholder.currentScoringSystem = self.selectedScore
            NetworkManager.getMyRestApi().setSelectedScore(self.selectedScore)
        }
    }
    
    private func handleSelectedScore(_ selectedScore: String){
        self.selectedScore = selectedScore
        DispatchQueue.main.async {
            if selectedScore.isEmpty {
                for i in 0..<self.allSwitches.count {
                    if i == 0 {
                        self.allSwitches[i].isOn = true
                    } else {
                        self.allSwitches[i].isOn = false
                    }
                }
            } else {
                for (pid, sw1) in self.packageIdToSwitch {
                    if pid == selectedScore {
                        sw1.isOn = true
                    } else {
                        sw1.isOn = false
                    }
                }
            }
            self.loader.isHidden = true
        }
    }
    
    private func handlePremiumPackages(_ packages:[PremiumPackage]){
        self.premiumPackages = packages
        for p in self.premiumPackages {
            switch p.id {
                case "TOP_ANALYSTS_SCORES":
                self.setDic(p.id, sw: self.topAnalysts)
                    break
                case "PREMIUM_PRECISION_ALPHA_PRICE_DYNAMICS":
                self.setDic(p.id, sw:self.paProbUp)
                    break
                case "STOCKTWITS_SENTIMENT":
                self.setDic(p.id, sw:self.stocktwits)
                    break
                case "PREMIUM_BRAIN_LANGUAGE_METRICS_ALL":
                    //unused
                    break
                case "PREMIUM_BRAIN_RANKING_21_DAYS":
                self.setDic(p.id, sw:self.brain21return)
                    break
                case "PREMIUM_BRAIN_SENTIMENT_30_DAYS":
                self.setDic(p.id, sw:self.brain30sent)
                    break
                case "PREMIUM_KAVOUT_KSCORE":
                self.setDic(p.id, sw:self.kavout)
                    break
                default:
                    break
            }
        }
        NetworkManager.getMyRestApi().getSelectedScore(completionHandler: handleSelectedScore)
    }
    
    private func setDic(_ pid:String?, sw:UISwitch){
        if let id = pid {
            self.packageIdToSwitch[id] = sw
        }
    }
    
    private func setSelectedScore(_ sw1:UISwitch){
        for (pid, sw2) in self.packageIdToSwitch {
            if sw1 == sw2 {
                self.selectedScore = pid
                break
            }
        }
    }
    
    @IBAction func userCustomized(_ sender: Any) {
        self.turnOffAllSwitchesExcept(sender as! UISwitch)
    }
    @IBAction func analystRecs(_ sender: Any) {
        self.turnOffAllSwitchesExcept(sender as! UISwitch)
    }
    @IBAction func priceTargets(_ sender: Any) {
        self.turnOffAllSwitchesExcept(sender as! UISwitch)
    }
    @IBAction func topAnalysts(_ sender: Any) {
        self.turnOffAllSwitchesExcept(sender as! UISwitch)
    }
    @IBAction func kavout(_ sender: Any) {
        self.turnOffAllSwitchesExcept(sender as! UISwitch)
    }
    @IBAction func brain30sent(_ sender: Any) {
        self.turnOffAllSwitchesExcept(sender as! UISwitch)
    }
    @IBAction func brain21return(_ sender: Any) {
        self.turnOffAllSwitchesExcept(sender as! UISwitch)
    }
    @IBAction func stocktwits(_ sender: Any) {
        self.turnOffAllSwitchesExcept(sender as! UISwitch)
    }
    @IBAction func precisionAlpha(_ sender: Any) {
        self.turnOffAllSwitchesExcept(sender as! UISwitch)
    }
    
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func turnOffAllSwitchesExcept(_ exceptSw:UISwitch){
        self.changeMade = true
        for (pid, sw1) in self.packageIdToSwitch {
            if sw1 == exceptSw {
                sw1.isOn = true
                self.selectedScore = pid
            } else {
                sw1.isOn = false
            }
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
