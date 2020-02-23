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
    @IBOutlet weak var dateE1: FormattedNumberLabel!
    @IBOutlet weak var epsE1: FormattedNumberLabel!
    @IBOutlet weak var consensusE1: FormattedNumberLabel!
    @IBOutlet weak var numEstimatesE1: FormattedNumberLabel!
    @IBOutlet weak var dateE2: FormattedNumberLabel!
    @IBOutlet weak var epsE2: FormattedNumberLabel!
    @IBOutlet weak var consensusE2: FormattedNumberLabel!
    @IBOutlet weak var numEstimatesE2: FormattedNumberLabel!
    @IBOutlet weak var dateE3: FormattedNumberLabel!
    @IBOutlet weak var epsE3: FormattedNumberLabel!
    @IBOutlet weak var consensusE3: FormattedNumberLabel!
    @IBOutlet weak var numEstimatesE3: FormattedNumberLabel!
    @IBOutlet weak var dateE4: FormattedNumberLabel!
    @IBOutlet weak var epsE4: FormattedNumberLabel!
    @IBOutlet weak var consensusE4: FormattedNumberLabel!
    @IBOutlet weak var numEstimatesE4: FormattedNumberLabel!
    
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
                self.epsChart.setup(company: self.company)
                self.peChart.setup(company: self.company)
            }
        }
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
