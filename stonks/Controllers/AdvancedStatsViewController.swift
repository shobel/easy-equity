//
//  AdvancedStatsViewController.swift
//  stonks
//
//  Created by Samuel Hobel on 9/8/19.
//  Copyright © 2019 Samuel Hobel. All rights reserved.
//

import UIKit

class AdvancedStatsViewController: UIViewController, StatsVC {
    
    @IBOutlet weak var revPerShare: FormattedNumberLabel!
    @IBOutlet weak var debtToEquity: FormattedNumberLabel!
    @IBOutlet weak var profitMargin: FormattedNumberLabel!
    @IBOutlet weak var entValue: FormattedNumberLabel!
    @IBOutlet weak var evPerRev: FormattedNumberLabel!
    @IBOutlet weak var priceToSales: FormattedNumberLabel!
    @IBOutlet weak var priceToBook: FormattedNumberLabel!
    @IBOutlet weak var peFWD: FormattedNumberLabel!
    @IBOutlet weak var pegRatio: FormattedNumberLabel!
    
    private var company:Company!
    private var isLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isLoaded = true
        self.company = Dataholder.selectedCompany!
        updateData()
    }
    
    func updateData() {
        self.company = Dataholder.selectedCompany!
        if (isLoaded){
            DispatchQueue.main.async {
                if let x = self.company.advancedStats?.revenuePerShare {
                    self.revPerShare.setValue(value: String(x), format: FormattedNumberLabel.Format.NUMBER)
                }
                if let x = self.company.advancedStats?.debtToEquity {
                    self.debtToEquity.setValue(value: String(x), format: FormattedNumberLabel.Format.NUMBER)
                }
                if let x = self.company.advancedStats?.profitMargin {
                    self.profitMargin.setValue(value: String(x), format: FormattedNumberLabel.Format.NUMBER)
                }
                if let x = self.company.advancedStats?.enterpriseValue {
                    self.entValue.setValue(value: String(x), format: FormattedNumberLabel.Format.NUMBER)
                }
                if let x = self.company.advancedStats?.enterpriseValueToRevenue {
                    self.evPerRev.setValue(value: String(x), format: FormattedNumberLabel.Format.NUMBER)
                }
                if let x = self.company.advancedStats?.priceToSales {
                    self.priceToSales.setValue(value: String(x), format: FormattedNumberLabel.Format.NUMBER)
                }
                if let x = self.company.advancedStats?.priceToBook {
                    self.priceToBook.setValue(value: String(x), format: FormattedNumberLabel.Format.NUMBER)
                }
                if let x = self.company.advancedStats?.forwardPERatio {
                    self.peFWD.setValue(value: String(x), format: FormattedNumberLabel.Format.NUMBER)
                }
                if let x = self.company.advancedStats?.pegRatio {
                    self.pegRatio.setValue(value: String(x), format: FormattedNumberLabel.Format.NUMBER)
                }
            }
        }
    }
    
    func getContentHeight() -> CGFloat {
        if isLoaded {
            return self.view.bounds.height
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
