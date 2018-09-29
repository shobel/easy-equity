//
//  LandingViewController.swift
//  stonks
//
//  Created by Samuel Hobel on 9/27/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import UIKit

class LandingViewController: UIViewController {
    
    var apiManager:StockAPIManager = StockAPIManager.shared
    var dataFetcher: StockDataAPI!
    var currentTicker = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataFetcher = apiManager.getStockDataAPI()
    }
    
    @IBAction func getQuoteButtonPressed(_ sender: Any) {
        dataFetcher.getChart(timeInterval: Constants.TimeIntervals.day)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
