//
//  KeyStatsViewController.swift
//  stonks
//
//  Created by Samuel Hobel on 8/20/19.
//  Copyright © 2019 Samuel Hobel. All rights reserved.
//

import UIKit

class KeyStatsViewController: UIViewController, StatsVC {
    
    @IBOutlet weak var marketCap: FormattedNumberLabel!
    @IBOutlet weak var beta: FormattedNumberLabel!
    @IBOutlet weak var dividend: FormattedNumberLabel!
    @IBOutlet weak var pe: FormattedNumberLabel!
    @IBOutlet weak var eps: FormattedNumberLabel!
    @IBOutlet weak var float: FormattedNumberLabel!
    @IBOutlet weak var volume: FormattedNumberLabel!
    @IBOutlet weak var volume10: FormattedNumberLabel!
    @IBOutlet weak var volume30: FormattedNumberLabel!
    @IBOutlet weak var week52high: FormattedNumberLabel!
    @IBOutlet weak var week52low: FormattedNumberLabel!
    @IBOutlet weak var week52change: FormattedNumberLabel!
    
    private var company:Company!
    private var isLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isLoaded = true
        self.company = Dataholder.watchlistManager.selectedCompany!
        updateData()
    }
    
    func updateData() {
        self.company = Dataholder.watchlistManager.selectedCompany!
        if (isLoaded){
            DispatchQueue.main.async {
                if let x = self.company.keyStats?.marketcap {
                    self.marketCap.setValue(value: String(x), format: FormattedNumberLabel.Format.NUMBER)
                }
                if let x = self.company.keyStats?.beta {
                    self.beta.setValue(value: String(x), format: FormattedNumberLabel.Format.NUMBER)
                }
                if let x = self.company.keyStats?.dividendYield {
                    self.dividend.setValue(value: String(x), format: FormattedNumberLabel.Format.NUMBER)
                }
                if let x = self.company.keyStats?.peRatio {
                    self.pe.setValue(value: String(x), format: FormattedNumberLabel.Format.NUMBER)
                }
                if let x = self.company.keyStats?.ttmEPS {
                    self.eps.setValue(value: String(x), format: FormattedNumberLabel.Format.NUMBER)
                }
                if let x = self.company.keyStats?.float {
                    self.float.setValue(value: String(x), format: FormattedNumberLabel.Format.NUMBER)
                }
//                if let x = self.company.quote?.avgTotalVolume {
//                    self.volume.setValue(value: String(x), format: FormattedNumberLabel.Format.NUMBER)
//                }
//                if let x = self.company.keyStats?.avg10Volume {
//                    self.volume10.setValue(value: String(x), format: FormattedNumberLabel.Format.NUMBER)
//                }
//                if let x = self.company.keyStats?.avg30Volume {
//                    self.volume30.setValue(value: String(x), format: FormattedNumberLabel.Format.NUMBER)
//                }
//                if let x = self.company.keyStats?.week52high {
//                    self.week52high.setValue(value: String(x), format: FormattedNumberLabel.Format.NUMBER)
//                }
//                if let x = self.company.keyStats?.week52low {
//                    self.week52low.setValue(value: String(x), format: FormattedNumberLabel.Format.NUMBER)
//                }
//                if let x = self.company.keyStats?.week52change {
//                    self.week52change.setValue(value: String(x), format: FormattedNumberLabel.Format.PERCENT)
//                }
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
