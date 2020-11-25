//
//  MarketViewController.swift
//  stonks
//
//  Created by Samuel Hobel on 11/23/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import UIKit
import GaugeKit
class MarketViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var overallFearGreed: UILabel!
    @IBOutlet weak var overallGauge: Gauge!
    private var indicators:[FearGreedIndicator] = []
    private var overallValue:Int = 0
    
    private var sectorPerformances:[SectorPerformance] = []
    private var economyWeekly:[EconomyWeekly] = []
    private var economyMonthly:[EconomyMonthly] = []
    private var gdps:[Double] = []
    @IBOutlet weak var industryCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.industryCollection.delegate = self
        self.industryCollection.dataSource = self
        
        NetworkManager.getMyRestApi().getMarketAndEconomyData(completionHandler: { (overallFearGreed, indicators, sectors, economyWeekly, economyMonthly, gdps) in
            DispatchQueue.main.async {
                self.overallValue = overallFearGreed
                self.overallFearGreed.text = String(overallFearGreed)
                self.indicators = indicators
                self.overallGauge.rate = CGFloat(overallFearGreed)
                self.sectorPerformances = sectors
                self.economyWeekly = economyWeekly
                self.economyMonthly = economyMonthly
                self.gdps = gdps
                
                self.industryCollection.reloadData()
            }
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sectorPerformances.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sectorCell", for: indexPath) as! IndustryCollectionViewCell
        let sector = sectorPerformances[indexPath.row]
        cell.industryName.text = sector.name
        cell.performance.text = String(sector.performance ?? 0.0)
        return cell

    }
    

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? FearGreedViewController {
            dest.setValues(self.overallValue, indicators: self.indicators)
        }
    }
    
    @IBAction func cnnmoneyButtonTapped(_ sender: Any) {
        if let url = URL(string: String("http://www.cnn.com")) {
            UIApplication.shared.open(url)
        }
    }
    
}
