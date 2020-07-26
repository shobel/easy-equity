//
//  PredictionsViewController.swift
//  stonks
//
//  Created by Samuel Hobel on 8/25/19.
//  Copyright © 2019 Samuel Hobel. All rights reserved.
//

import UIKit

class PredictionsViewController: UIViewController, StatsVC {
    
    @IBOutlet weak var priceTarget: FormattedNumberLabel!
    @IBOutlet weak var numEstimatesPT: FormattedNumberLabel!
    @IBOutlet weak var datePT: FormattedNumberLabel!
    @IBOutlet weak var numBuys: FormattedNumberLabel!
    @IBOutlet weak var numHolds: FormattedNumberLabel!
    @IBOutlet weak var numSells: FormattedNumberLabel!
    
    @IBOutlet weak var contentView: UIView!
    
    private var company:Company!
    private var isLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.company = Dataholder.selectedCompany!
        self.isLoaded = true
        updateData();
    }
    
    func updateData() {
        self.company = Dataholder.selectedCompany!
        if (isLoaded){
            DispatchQueue.main.async {
                var numBuy = 0
                var numSell = 0
                var numHold = 0
                if let recommendations = self.company.recommendations {
                    for r in recommendations {
                        numBuy += r.ratingBuy! + r.ratingOverweight!
                        numHold += r.ratingHold!
                        numSell += r.ratingUnderweight! + r.ratingSell!
                    }
                    self.company.totalBuy = numBuy
                    self.company.totalHold = numHold
                    self.company.totalSell = numSell
                }
                self.numBuys.setValue(value: String(numBuy), format: FormattedNumberLabel.Format.NUMBER)
                self.numHolds.setValue(value: String(numHold), format: FormattedNumberLabel.Format.NUMBER)
                self.numSells.setValue(value: String(numSell), format: FormattedNumberLabel.Format.NUMBER)
            
                if let x = self.company.priceTarget?.priceTargetAverage {
                    self.priceTarget.setValue(value: String(x), format: FormattedNumberLabel.Format.NUMBER)
                }
                if let x = self.company.priceTarget?.numberOfAnalysts {
                    self.numEstimatesPT.setValue(value: String(x), format: FormattedNumberLabel.Format.NUMBER)
                }
                if let x = self.company.priceTarget?.updatedDate {
                    self.datePT.setValue(value: String(x), format: FormattedNumberLabel.Format.DATE)
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
