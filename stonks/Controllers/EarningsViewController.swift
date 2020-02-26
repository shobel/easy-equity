//
//  EarningsViewController.swift
//  stonks
//
//  Created by Samuel Hobel on 9/8/19.
//  Copyright © 2019 Samuel Hobel. All rights reserved.
//

import UIKit

class EarningsViewController: UIViewController, StatsVC {

    @IBOutlet weak var epsChart: EPSChart!
    @IBOutlet weak var peChart: PEChart!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var peFwdValue: UILabel!
    @IBOutlet weak var peValue: UILabel!
    @IBOutlet weak var eps: UILabel!
    @IBOutlet weak var epsDate: UILabel!
    @IBOutlet weak var estEps: UILabel!
    @IBOutlet weak var estEpsDate: UILabel!
    @IBOutlet weak var avg: UILabel!
    
    @IBOutlet weak var nextEarningsDate: UILabel!
    @IBOutlet weak var nextEarningsQuarter: UILabel!
    @IBOutlet weak var nextEarningsDaysLeft: UILabel!
    
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
                self.epsChart.setup(company: self.company, earningsDelegate: self)
                self.peChart.setup(company: self.company, delegate: self)
                if let est = self.company.estimates {
                    self.nextEarningsQuarter.text = est.fiscalPeriod
                    if let estDate = est.getDate() {
                        let dateformatter = DateFormatter()
                        dateformatter.dateFormat = "MMM d, yyyy"
                        self.nextEarningsDate.text = dateformatter.string(from: estDate)
                        self.nextEarningsDaysLeft.text = "\(GeneralUtility.daysUntil(date: estDate)) days"
                    } else {
                        self.nextEarningsDaysLeft.text = ""
                    }
                }
            }
        }
    }
    
    public func updatePELegendValues(pe: String, peFwd: String){
        self.peFwdValue.text = peFwd
        self.peValue.text = pe
    }
    
    public func updateEPSLegendValues(eps: String, epsDate: String, epsFwd: String, epsFwdDate: String, avg: String){
        self.eps.text = eps
        self.epsDate.text = epsDate
        self.estEpsDate.text = epsFwdDate
        self.estEps.text = epsFwd
        self.avg.text = avg
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
