//
//  GeneralInfoViewController.swift
//  stonks
//
//  Created by Samuel Hobel on 8/20/19.
//  Copyright © 2019 Samuel Hobel. All rights reserved.
//

import UIKit

class GeneralInfoViewController: UIViewController, StatsVC {
    
    @IBOutlet weak var sector: UILabel!
    @IBOutlet weak var industry: UILabel!
    @IBOutlet weak var exchange: UILabel!
    @IBOutlet weak var descrip: UILabel!
    
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
        if (isLoaded) {
            DispatchQueue.main.async {
                self.sector.text = self.company.generalInfo?.sector
                self.industry.text = self.company.generalInfo?.industry
                self.exchange.text = self.company.generalInfo?.exchange
                self.descrip.text = self.company.generalInfo?.description
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
