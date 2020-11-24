//
//  MarketViewController.swift
//  stonks
//
//  Created by Samuel Hobel on 11/23/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import UIKit
import GaugeKit
class FearGreedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var fearGreedTable: UITableView!
    @IBOutlet weak var overallGauge: Gauge!
    @IBOutlet weak var overallValueLabel: UILabel!
    private var indicators: [FearGreedIndicator] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fearGreedTable.delegate = self
        self.fearGreedTable.dataSource = self

    }
    
    public func setValues(_ overallFearGreed: Int, indicators: [FearGreedIndicator]) {
        DispatchQueue.main.async {
            self.overallValueLabel.text = String(overallFearGreed)
            self.overallGauge.rate = CGFloat(overallFearGreed)
            self.indicators = indicators
            self.fearGreedTable.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.indicators.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "indicatorCell", for: indexPath) as! FearGreedTableViewCell
        let indicator = indicators[indexPath.row]
        cell.title.text = indicator.name
        cell.gauge.rate = CGFloat(self.getFearGreedValueFromString(indicator.indicatorValue ?? ""))
        cell.indicatorText.text = indicator.indicatorDescription
        return cell
    }

    private func getFearGreedValueFromString(_ stringValue:String) -> Int {
        switch stringValue {
        case "Extreme Greed":
            return 95
        case "Greed":
            return 75
        case "Neutral":
            return 50
        case "Fear":
            return 25
        case "Extreme Fear":
            return 5
        default:
            return 50
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
