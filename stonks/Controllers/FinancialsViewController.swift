//
//  FinancialsViewController.swift
//  stonks
//
//  Created by Samuel Hobel on 9/8/19.
//  Copyright © 2019 Samuel Hobel. All rights reserved.
//

import UIKit

class FinancialsViewController: UIViewController, StatsVC {
    
    @IBOutlet weak var netIncome: FormattedNumberLabel!
    @IBOutlet weak var cashFlow: FormattedNumberLabel!
    @IBOutlet weak var totalCash: FormattedNumberLabel!
    @IBOutlet weak var cashChange: FormattedNumberLabel!
    @IBOutlet weak var debt: FormattedNumberLabel!
    @IBOutlet weak var revenue: FormattedNumberLabel!
    @IBOutlet weak var assets: FormattedNumberLabel!
    @IBOutlet weak var liabilities: FormattedNumberLabel!
    @IBOutlet weak var research: FormattedNumberLabel!
    @IBOutlet weak var opex: FormattedNumberLabel!
    @IBOutlet weak var se: FormattedNumberLabel!
    @IBOutlet weak var contentView: UIView!
    
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
                if let ni = self.company.financials?.netIncome {
                    self.netIncome.setValue(value: String(ni), format: FormattedNumberLabel.Format.NUMBER)
                }
                if let cf = self.company.financials?.cashFlow {
                    self.cashFlow.setValue(value: String(cf), format: FormattedNumberLabel.Format.NUMBER)
                }
                if let tc = self.company.financials?.totalCash {
                    self.totalCash.setValue(value: String(tc), format: FormattedNumberLabel.Format.NUMBER)
                }
                if let cf = self.company.financials?.cashChange {
                    self.cashChange.setValue(value: String(cf), format: FormattedNumberLabel.Format.NUMBER)
                }
                if let cf = self.company.financials?.totalDebt {
                    self.debt.setValue(value: String(cf), format: FormattedNumberLabel.Format.NUMBER)
                }
                if let cf = self.company.financials?.totalRevenue {
                    self.revenue.setValue(value: String(cf), format: FormattedNumberLabel.Format.NUMBER)
                }
                if let cf = self.company.financials?.totalAssets {
                    self.assets.setValue(value: String(cf), format: FormattedNumberLabel.Format.NUMBER)
                }
                if let cf = self.company.financials?.totalLiabilities {
                    self.liabilities.setValue(value: String(cf), format: FormattedNumberLabel.Format.NUMBER)
                }
                if let cf = self.company.financials?.researchAndDevelopment {
                    self.research.setValue(value: String(cf), format: FormattedNumberLabel.Format.NUMBER)
                }
                if let cf = self.company.financials?.operatingExpense {
                    self.opex.setValue(value: String(cf), format: FormattedNumberLabel.Format.NUMBER)
                }
                if let cf = self.company.financials?.shareholderEquity {
                    self.se.setValue(value: String(cf), format: FormattedNumberLabel.Format.NUMBER)
                }
            }
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
