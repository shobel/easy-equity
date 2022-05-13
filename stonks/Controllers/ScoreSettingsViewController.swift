//
//  ScoreSettingsViewController.swift
//  stonks
//
//  Created by Samuel Hobel on 10/24/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import UIKit

class ScoreSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var scoreSettings:ScoreSettings = ScoreSettings()
    var variableNames:[String:String] = [:]
    var variables:[String:[String]] = [:]
    
    @IBOutlet weak var totalWeight: UILabel!
    
    @IBOutlet weak var valuationTable: UITableView!
    @IBOutlet weak var valuationHeight: NSLayoutConstraint!
    @IBOutlet weak var valuationWeight: UITextField!
    
    @IBOutlet weak var futureTable: UITableView!
    @IBOutlet weak var futureHeight: NSLayoutConstraint!
    @IBOutlet weak var futureWeight: UITextField!
    
    @IBOutlet weak var pastTable: UITableView!
    @IBOutlet weak var pastWeight: UITextField!
    @IBOutlet weak var pastHeight: NSLayoutConstraint!
    
    @IBOutlet weak var healthTable: UITableView!
    @IBOutlet weak var healthHeight: NSLayoutConstraint!
    @IBOutlet weak var healthWeight: UITextField!
    
    private var valuation = "valuation"
    private var future = "future"
    private var past = "past"
    private var health = "health"
    
    private var somethingChanged:Bool = false
    public var parentVC:UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.valuationTable.delegate = self
        self.valuationTable.dataSource = self
        self.futureTable.delegate = self
        self.futureTable.dataSource = self
        self.pastTable.delegate = self
        self.pastTable.dataSource = self
        self.healthTable.delegate = self
        self.healthTable.dataSource = self
        self.valuationTable.backgroundColor = .white
        self.futureTable.backgroundColor = .white
        self.pastTable.backgroundColor = .white
        self.healthTable.backgroundColor = .white
        
        self.valuationWeight.text = "25.0"
        self.futureWeight.text = "25.0"
        self.pastWeight.text = "25.0"
        self.healthWeight.text = "25.0"
        
        NetworkManager.getMyRestApi().getSettingsAndVariables { (scoreSettings, variableNamesMap, variableMap) in
            self.scoreSettings = scoreSettings
            self.variableNames = variableNamesMap
            self.variables = variableMap
            DispatchQueue.main.async {
                self.valuationHeight.constant = CGFloat((self.variables[self.valuation]!).count) * 40
                self.futureHeight.constant = CGFloat((self.variables[self.future]!).count) * 40
                self.pastHeight.constant = CGFloat((self.variables[self.past]!).count) * 40
                self.healthHeight.constant = CGFloat((self.variables[self.health]!).count) * 40
                
                if let w = self.scoreSettings.weightings {
                    self.valuationWeight.text = String(w[self.valuation]!)
                    self.futureWeight.text = String(w[self.future]!)
                    self.pastWeight.text = String(w[self.past]!)
                    self.healthWeight.text = String(w[self.health]!)

                }

                self.valuationTable.reloadData()
                self.futureTable.reloadData()
                self.pastTable.reloadData()
                self.healthTable.reloadData()
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if somethingChanged {
            Dataholder.lastScoreConfigChange = Date().timeIntervalSince1970
            NetworkManager.getMyRestApi().setScoresSettings(scoreSettings: self.scoreSettings) { (result) in
                if let p = self.parentVC as? AnalysisViewController {
                    p.fetchScores()
                } else if let p = self.parentVC as? ScoresViewController {
                    p.fetchScores()
                }
            }
        }
    }
    
    private func updateTotalWeighting(){
        var total = 0.0
        for category in self.scoreSettings.weightings! {
            total += Double(category.value)
        }
        DispatchQueue.main.async {
            self.totalWeight.text = String(format: "%.0f", total) + "%"
            if total == 100 {
                self.totalWeight.textColor = Constants.green
            } else {
                self.totalWeight.textColor = Constants.darkPink
            }
        }
    }
    
    public func switchChanged(variableName:String, isOn:Bool){
        if isOn {
            let index = self.scoreSettings.disabled?.firstIndex(of: variableName)
            if let index = index {
                self.scoreSettings.disabled?.remove(at: index)
            }
        } else {
            if !(self.scoreSettings.disabled?.contains(variableName) ?? true) {
                self.scoreSettings.disabled?.append(variableName)
            }
        }
        self.somethingChanged = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.restorationIdentifier == "valuationTable" {
            if let t = self.variables[valuation] {
                return t.count
            }
        } else if tableView.restorationIdentifier == "futureTable" {
            if let t = self.variables[future] {
                return t.count
            }
        } else if tableView.restorationIdentifier == "pastTable" {
            if let t = self.variables[past] {
                return t.count
            }
        } else if tableView.restorationIdentifier == "healthTable" {
            if let t = self.variables[health] {
                return t.count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "variableCell", for: indexPath) as! VariableTableViewCell
        cell.parent = self
        var variableName:String = ""
        if tableView.restorationIdentifier == "valuationTable" {
            if let t = self.variables[valuation] {
                variableName = self.variableNames[t[indexPath.row]] ?? ""
                cell.variable = t[indexPath.row]
                cell.onoff.isOn = !(self.scoreSettings.disabled ?? []).contains(t[indexPath.row])
            }
        } else if tableView.restorationIdentifier == "futureTable" {
            if let t = self.variables[future] {
                variableName = self.variableNames[t[indexPath.row]] ?? ""
                cell.variable = t[indexPath.row]
                cell.onoff.isOn = !(self.scoreSettings.disabled ?? []).contains(t[indexPath.row])
            }
        } else if tableView.restorationIdentifier == "pastTable" {
            if let t = self.variables[past] {
                variableName = self.variableNames[t[indexPath.row]] ?? ""
                cell.variable = t[indexPath.row]
                cell.onoff.isOn = !(self.scoreSettings.disabled ?? []).contains(t[indexPath.row])
            }
        } else if tableView.restorationIdentifier == "healthTable" {
            if let t = self.variables[health] {
                variableName = self.variableNames[t[indexPath.row]] ?? ""
                cell.variable = t[indexPath.row]
                cell.onoff.isOn = !(self.scoreSettings.disabled ?? []).contains(t[indexPath.row])
            }
        }
        cell.variableName.text = variableName
        return cell
    }
    

    @IBAction func valuationWeightChanged(_ sender: Any) {
        self.weightingChanged(self.valuation, sender: sender)
    }
    
    @IBAction func futureWeightChanged(_ sender: Any) {
        self.weightingChanged(self.future, sender: sender)
    }
    
    @IBAction func pastWeightChanged(_ sender: Any) {
        self.weightingChanged(self.past, sender: sender)
    }
    
    @IBAction func healthWeightChanged(_ sender: Any) {
        self.weightingChanged(self.health, sender: sender)
    }
    
    private func weightingChanged(_ variable:String, sender:Any){
        if let sender = sender as? UITextField, let value = Double(sender.text!) {
            self.scoreSettings.weightings![variable] = value
            somethingChanged = true
            self.updateTotalWeighting()
        }
    }
    
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
// 
//    }
    

}
