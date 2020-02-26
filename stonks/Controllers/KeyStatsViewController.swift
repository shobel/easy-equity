//
//  KeyStatsViewController.swift
//  stonks
//
//  Created by Samuel Hobel on 8/20/19.
//  Copyright © 2019 Samuel Hobel. All rights reserved.
//

import UIKit
protocol StatsVC {
    func updateData()
    func getContentHeight() -> CGFloat
}
class KeyStatsViewController: UIViewController, StatsVC {
    
    @IBOutlet weak var marketCap: FormattedNumberLabel!
    @IBOutlet weak var beta: FormattedNumberLabel!
    @IBOutlet weak var dividend: FormattedNumberLabel!
    @IBOutlet weak var pe: FormattedNumberLabel!
    @IBOutlet weak var eps: FormattedNumberLabel!
    @IBOutlet weak var float: FormattedNumberLabel!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var evLabel: FormattedNumberLabel!
    @IBOutlet weak var nextDividend: FormattedNumberLabel!
    @IBOutlet weak var pefwd: FormattedNumberLabel!
    @IBOutlet weak var peg: FormattedNumberLabel!
    @IBOutlet weak var sharesOut: FormattedNumberLabel!
    @IBOutlet weak var pb: FormattedNumberLabel!
    @IBOutlet weak var ps: FormattedNumberLabel!
    @IBOutlet weak var rps: FormattedNumberLabel!
    @IBOutlet weak var de: FormattedNumberLabel!
    @IBOutlet weak var evrev: FormattedNumberLabel!
    
    
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

            }
        }
    }
     
    func getContentHeight() -> CGFloat {
        if self.isLoaded {
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
