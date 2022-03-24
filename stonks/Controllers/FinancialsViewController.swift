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
    
    @IBOutlet weak var epsChart: EPSChart!
    @IBOutlet weak var peChart: PEChart!
    @IBOutlet weak var peFwdValue: UILabel!
    @IBOutlet weak var peValue: UILabel!
    @IBOutlet weak var eps: UILabel!
    @IBOutlet weak var epsDate: UILabel!
    @IBOutlet weak var estEps: UILabel!
    @IBOutlet weak var estEpsDate: UILabel!
    
    @IBOutlet weak var nextEarningsDate: UILabel!
    @IBOutlet weak var nextEarningsQuarter: UILabel!
    @IBOutlet weak var nextEarningsDaysLeft: UILabel!
    
    private var company:Company!
    private var isLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.chartSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        let font = UIFont(name: "HelveticaNeue", size: 12)!
        self.chartSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)

        self.company = Dataholder.selectedCompany!
    }
    
    func handleFinancials(earnings: [Earnings], cashflow: [CashFlow], cashflowAnnual: [CashFlow], income: [Income], incomeAnnual: [Income], balanceSheets:[BalanceSheet], balanceSheetsAnnual:[BalanceSheet]){
        self.company.cashflow = cashflow.count > 0 ? cashflow : nil
        self.company.cashflowAnnual = cashflowAnnual.count > 0 ? cashflowAnnual : nil
        self.company.income = income.count > 0 ? income : nil
        self.company.incomeAnnual = incomeAnnual.count > 0 ? incomeAnnual : nil
        self.company.balanceSheets = balanceSheets.count > 0 ? balanceSheets : nil
        self.company.balanceSheetsAnnual = balanceSheetsAnnual.count > 0 ? balanceSheetsAnnual : nil
        self.company.earnings = earnings.count > 0 ? earnings : nil
        self.setData()
    }
    
    func updateData() {
        if (!isLoaded){
            if let p = self.parent?.parent?.parent as? StockDetailsVC {
                p.hideLoader(false)
            }
            NetworkManager.getMyRestApi().getThirdTabData(symbol: self.company.symbol, completionHandler: handleFinancials)
        }
    }
    
    private func setData() {
        DispatchQueue.main.async {
            if self.company.cashflow != nil && self.company.cashflow!.count > 0 {
                self.company.cashflow!.sort(by: { (a, b) -> Bool in
                    return NumberFormatter.convertStringDateToInt(date: a.reportDate!) > NumberFormatter.convertStringDateToInt(date: b.reportDate!)
                })
            }
            if self.company.income != nil && self.company.income!.count > 0 {
                self.company.income!.sort(by: { (a, b) -> Bool in
                    return NumberFormatter.convertStringDateToInt(date: a.reportDate!) > NumberFormatter.convertStringDateToInt(date: b.reportDate!)
                })
            }
            if self.company.balanceSheets != nil && self.company.balanceSheets!.count > 0 {
                self.company.balanceSheets!.sort(by: { (a, b) -> Bool in
                    return NumberFormatter.convertStringDateToInt(date: a.reportDate!) > NumberFormatter.convertStringDateToInt(date: b.reportDate!)
                })
            }
            if self.company.cashflowAnnual?.count == 0 && self.company.incomeAnnual?.count == 0 && self.company.balanceSheets?.count == 0{
                    return
            }
            let mostRecentCashflow:CashFlow = self.company.cashflowAnnual![0]
            let mostRecentIncome:Income = self.company.incomeAnnual![0]
            let mostRecentBalanceSheet:BalanceSheet = self.company.balanceSheetsAnnual![0]
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
            
            if let tc = mostRecentBalanceSheet.cashAndCashEquivalents {
                self.totalCash.setValue(value: String(tc), format: FormattedNumberLabel.Format.NUMBER)
            }
            if let cf = mostRecentBalanceSheet.totalDebt {
                self.debt.setValue(value: String(cf), format: FormattedNumberLabel.Format.NUMBER)
            }
            if let cf = mostRecentIncome.totalRevenue {
                self.revenue.setValue(value: String(cf), format: FormattedNumberLabel.Format.NUMBER)
            }
            if let cf = mostRecentIncome.ebitda {
                self.ebitda.setValue(value: String(cf), format: FormattedNumberLabel.Format.NUMBER)
            }
            if let x = self.company.advancedStats?.profitMargin {
                self.profitMargin.setValue(value: String(x), format: FormattedNumberLabel.Format.NUMBER)
            }
            
            self.epsChart.setup(company: self.company, parentDelegate: self)
            self.peChart.setup(company: self.company, delegate: self)
            if let inc = self.company.income, inc.count>0, let q = self.company.quote {
                let latestPeriod = inc[0].period
                //don't delete these below, just not working right now
                var futureYear:Int = 0
                var hasYear:Bool = false
                if latestPeriod != nil && latestPeriod!.contains(" ") {
                    let year = latestPeriod!.components(separatedBy: " ")[1]
                    futureYear = Int(year)!
                    hasYear = true
                }
                let quarter = latestPeriod?.components(separatedBy: " ")[0]
                let quarterNum = quarter?.components(separatedBy: "Q")[1]
                var futurePeriod = Int(quarterNum!)! + 1
                if futurePeriod > 4 {
                    futurePeriod = 1
                    if hasYear {
                        futureYear = futureYear + 1
                    }
                }
                if hasYear {
                    self.nextEarningsQuarter.text = String("Q\(futurePeriod) \(futureYear)")
                } else {
                    self.nextEarningsQuarter.text = String("Q\(futurePeriod)")
                }
                if let nextReportDate = q.earningsAnnouncement {
                    let dateformatter = DateFormatter()
                    dateformatter.locale = Locale(identifier: "en_US_POSIX")
                    dateformatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SZ"
                    let date = dateformatter.date(from: nextReportDate)
                    dateformatter.dateFormat = "MMM d, yyyy"
                    if date != nil {
                        self.nextEarningsDate.text = dateformatter.string(from: date!)
                        self.nextEarningsDaysLeft.text = "\(GeneralUtility.daysUntil(date: date!)) days"
                    }
                } else {
                    self.nextEarningsDaysLeft.text = ""
                }
            }
        }
        self.isLoaded = true
        DispatchQueue.main.async {
            if let p = self.parent?.parent?.parent as? StockDetailsVC {
                p.adjustContentHeight(vc: self)
                p.hideLoader(true)
            }
        }
    }
    
    public func updatePELegendValues(pe: String, peFwd: String){
        self.peFwdValue.text = peFwd
        self.peValue.text = pe
    }
    
    public func updateEPSLegendValues(eps: String, epsDate: String, epsFwd: String, epsFwdDate: String){
        self.eps.text = eps
        self.epsDate.text = epsDate
        self.estEpsDate.text = epsFwdDate
        self.estEps.text = epsFwd
    }
    
    @IBAction func incomeChartModeChanged(_ sender: Any) {
        self.incomeChart.changeChartMode(chartMode: self.chartSegmentedControl.titleForSegment(at: self.chartSegmentedControl.selectedSegmentIndex)!)
    }
    
    func getContentHeight() -> CGFloat {
        return self.contentView.bounds.height
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
