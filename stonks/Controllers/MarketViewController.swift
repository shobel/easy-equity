//
//  MarketViewController.swift
//  stonks
//
//  Created by Samuel Hobel on 11/23/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import UIKit
import GaugeKit
class MarketViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var overallFearGreed: UILabel!
    @IBOutlet weak var overallGauge: Gauge!
    private var indicators:[FearGreedIndicator] = []
    private var overallValue:Int = 0
    
    private var sectorPerformances:[SectorPerformance] = []
    @IBOutlet weak var sectorPerfDate: UILabel!
    private var ew:[EconomyMetric] = []
    private var em:[EconomyMetric] = []
    private var gdps:[Double] = []
    @IBOutlet weak var gdpStartDate: UILabel!
    @IBOutlet weak var gdpEndDate: UILabel!
    @IBOutlet weak var gdpChart: SimplestLineChart!
    @IBOutlet weak var industryCollection: UICollectionView!
    
    @IBOutlet weak var weeklyEconomyTable: UITableView!
    @IBOutlet weak var monthlyEconomyTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.industryCollection.delegate = self
        self.industryCollection.dataSource = self
        self.weeklyEconomyTable.delegate = self
        self.weeklyEconomyTable.dataSource = self
        self.monthlyEconomyTable.delegate = self
        self.monthlyEconomyTable.dataSource = self
        self.weeklyEconomyTable.backgroundColor
            = .white
        self.monthlyEconomyTable.backgroundColor = .white
        
        NetworkManager.getMyRestApi().getMarketAndEconomyData(completionHandler: { (overallFearGreed, indicators, sectors, economyWeekly, economyMonthly, gdps, gdpStartDate, gdpEndDate) in
            DispatchQueue.main.async {
                self.overallValue = overallFearGreed
                self.overallFearGreed.text = String(overallFearGreed)
                self.indicators = indicators
                self.overallGauge.rate = CGFloat(overallFearGreed)
                self.sectorPerformances = sectors
                if self.sectorPerformances.count > 0, let updated = sectors[0].updated {
                    self.sectorPerfDate.text = NumberFormatter.timestampToDatestring(Double(updated))
                } else {
                    self.sectorPerfDate.text = ""
                }
                
                self.ew = EconomyWeekly.getValueArrayFromEconomyWeeklies(weeklies: economyWeekly)
                self.em = EconomyMonthly.getValueArrayFromEconomyMonthlies(monthlies: economyMonthly)
                self.gdps = gdps.reversed()
                
                self.gdpStartDate.text = gdpStartDate
                self.gdpEndDate.text = gdpEndDate
                self.gdpChart.setData([self.gdps], colors: [])
                self.gdpChart.setDrawZeroLine()
                self.gdpChart.setHideLeftAxis()
                self.industryCollection.reloadData()
                self.weeklyEconomyTable.reloadData()
                self.monthlyEconomyTable.reloadData()
            }
        })
    }
    
    func getRealGDPFromPercentChanges(_ gdps:[Double]) -> [Double]{
        var realGdps:[Double] = []
        var currentValue = 1.0
        for i in 0..<gdps.count {
            let gdp = gdps[i]
            currentValue = currentValue + (currentValue * gdp/100.0)
            realGdps.append(currentValue)
        }
        return realGdps
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.restorationIdentifier == "weeklyEconomyTable" {
            return self.ew.count
        } else {
            return self.em.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:EconomyTableViewCell?
        var metric:EconomyMetric = EconomyMetric()
        if tableView.restorationIdentifier == "weeklyEconomyTable" {
            cell = tableView.dequeueReusableCell(withIdentifier: "weeklyEconomyCell", for: indexPath) as? EconomyTableViewCell
            metric = self.ew[indexPath.row]
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "monthlyEconomyCell", for: indexPath) as? EconomyTableViewCell
            metric = self.em[indexPath.row]
        }
        if let cell = cell {
            cell.name.text = metric.name
            cell.latestValue.text = NumberFormatter.formatNumber(num: metric.latestValue ?? 0.0)
            cell.lineChart.setData([metric.values], colors: [])
        }
        return cell ?? UITableViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sectorPerformances.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sectorCell", for: indexPath) as! IndustryCollectionViewCell
        let sector = sectorPerformances[indexPath.row]
        cell.industryName.text = sector.name
        cell.setPerformance(sector.performance ?? 0.0)
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
