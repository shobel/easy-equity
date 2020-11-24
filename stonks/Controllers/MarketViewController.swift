//
//  MarketViewController.swift
//  stonks
//
//  Created by Samuel Hobel on 11/23/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import UIKit
import GaugeKit
class MarketViewController: UIViewController {

    @IBOutlet weak var overallFearGreed: UILabel!
    @IBOutlet weak var overallGauge: Gauge!
    private var indicators:[FearGreedIndicator] = []
    private var overallValue:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NetworkManager.getMyRestApi().getFearGreedIndicators { (overallValue, indicators) in
            DispatchQueue.main.async {
                self.overallValue = overallValue
                self.overallFearGreed.text = String(overallValue)
                self.indicators = indicators
                self.overallGauge.rate = CGFloat(overallValue)
            }
        }
        
    }
    

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? FearGreedViewController {
            dest.setValues(self.overallValue, indicators: self.indicators)
        }
    }
    

}
