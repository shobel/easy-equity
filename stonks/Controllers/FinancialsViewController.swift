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
    @IBOutlet weak var capex: FormattedNumberLabel!
    @IBOutlet weak var opinc: FormattedNumberLabel!
    @IBOutlet weak var research: FormattedNumberLabel!
    @IBOutlet weak var opex: FormattedNumberLabel!
    @IBOutlet weak var ebitda: FormattedNumberLabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var profitMargin: FormattedNumberLabel!
    
    @IBOutlet weak var incomeChart: IncomeChart!
    @IBOutlet weak var chartSegmentedControl: UISegmentedControl!
    
    private var company:Company!
    private var isLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.chartSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        let font = UIFont(name: "Futura", size: 10)!
        self.chartSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)

        self.isLoaded = true
        self.company = Dataholder.selectedCompany!
        updateData()
    }
    
    func updateData() {
        self.company = Dataholder.selectedCompany!
        if (isLoaded){
            DispatchQueue.main.async {
                if self.company.cashflow != nil && self.company.cashflow!.count > 0
                    && self.company.income != nil && self.company.income!.count > 0 {
                    self.company.cashflow!.sort(by: { (a, b) -> Bool in
                        return NumberFormatter.convertStringDateToInt(date: a.reportDate!) > NumberFormatter.convertStringDateToInt(date: b.reportDate!)
                    })
                    self.company.income!.sort(by: { (a, b) -> Bool in
                        return NumberFormatter.convertStringDateToInt(date: a.reportDate!) > NumberFormatter.convertStringDateToInt(date: b.reportDate!)
                    })
                    let mostRecentCashflow:CashFlow = self.company.cashflow![0]
                    let mostRecentIncome:Income = self.company.income![0]
                    
                    if let ni = mostRecentCashflow.netIncome {
                        self.netIncome.setValue(value: String(ni), format: FormattedNumberLabel.Format.NUMBER)
                    }
                    if let cf = mostRecentCashflow.cashFlow {
                        self.cashFlow.setValue(value: String(cf), format: FormattedNumberLabel.Format.NUMBER)
                    }
                    if let cf = mostRecentCashflow.capitalExpenditures {
                        self.capex.setValue(value: String(cf), format: FormattedNumberLabel.Format.NUMBER)
                    }
                    if let cf = mostRecentCashflow.cashChange {
                        self.cashChange.setValue(value: String(cf), format: FormattedNumberLabel.Format.NUMBER)
                    }
                    if let cf = mostRecentIncome.operatingExpense {
                        self.opex.setValue(value: String(cf), format: FormattedNumberLabel.Format.NUMBER)
                    }
                    if let cf = mostRecentIncome.operatingIncome {
                        self.opinc.setValue(value: String(cf), format: FormattedNumberLabel.Format.NUMBER)
                    }
                    if let cf = mostRecentIncome.researchAndDevelopment {
                        self.research.setValue(value: String(cf), format: FormattedNumberLabel.Format.NUMBER)
                    }
                    
                    self.incomeChart.setup(company: self.company, financialDelegate: self)
                }
                if let tc = self.company.advancedStats?.totalCash {
                    self.totalCash.setValue(value: String(tc), format: FormattedNumberLabel.Format.NUMBER)
                }
                if let cf = self.company.advancedStats?.currentDebt {
                    self.debt.setValue(value: String(cf), format: FormattedNumberLabel.Format.NUMBER)
                }
                if let cf = self.company.advancedStats?.revenue {
                    self.revenue.setValue(value: String(cf), format: FormattedNumberLabel.Format.NUMBER)
                }
                if let cf = self.company.advancedStats?.ebitda {
                    self.ebitda.setValue(value: String(cf), format: FormattedNumberLabel.Format.NUMBER)
                }
                if let x = self.company.advancedStats?.profitMargin {
                    self.profitMargin.setValue(value: String(x), format: FormattedNumberLabel.Format.NUMBER)
                }

            }
        }
    }
    
    @IBAction func incomeChartModeChanged(_ sender: Any) {
        self.incomeChart.changeChartMode(chartMode: self.chartSegmentedControl.titleForSegment(at: self.chartSegmentedControl.selectedSegmentIndex)!)
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
