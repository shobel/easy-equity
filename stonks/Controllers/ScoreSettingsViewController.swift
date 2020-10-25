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
    
    @IBOutlet weak var technicalTable: UITableView!
    @IBOutlet weak var technicalHeight: NSLayoutConstraint!
    @IBOutlet weak var technicalWeight: UITextField!
    
    private var valuation = "valuation"
    private var future = "future"
    private var past = "past"
    private var health = "health"
    private var technical = "technical"
    
    private var somethingChanged:Bool = false
    
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
        self.technicalTable.delegate = self
        self.technicalTable.dataSource = self
        NetworkManager.getMyRestApi().getSettingsAndVariables { (scoreSettings, variableNamesMap, variableMap) in
            self.scoreSettings = scoreSettings
            self.variableNames = variableNamesMap
            self.variables = variableMap
            DispatchQueue.main.async {
                self.valuationHeight.constant = CGFloat((self.variables[self.valuation]!).count) * 40
                self.futureHeight.constant = CGFloat((self.variables[self.future]!).count) * 40
                self.pastHeight.constant = CGFloat((self.variables[self.past]!).count) * 40
                self.healthHeight.constant = CGFloat((self.variables[self.health]!).count) * 40
                self.technicalHeight.constant = CGFloat((self.variables[self.technical]!).count) * 40

                self.valuationTable.reloadData()
                self.futureTable.reloadData()
                self.pastTable.reloadData()
                self.healthTable.reloadData()
                self.technicalTable.reloadData()
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if somethingChanged {
            //save scoresettings00
        }
    }
    
    private func updateTotalWeighting(){
        var total = 0.0
        for category in self.scoreSettings.weightings! {
            total += Double(category.value)
        }
        self.totalWeight.text = String("\(total)%")
        if total == 100 {
            self.totalWeight.textColor = Constants.green
        } else {
            self.totalWeight.textColor = Constants.darkPink
        }
    }
    
    public func switchChanged(variableName:String, isOn:Bool){
        if isOn {
            self.scoreSettings.disabled?.remove(at: (self.scoreSettings.disabled?.firstIndex(of: variableName))!)
        } else {
            self.scoreSettings.disabled?.append(variableName)
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
        } else if tableView.restorationIdentifier == "technicalTable" {
            if let t = self.variables[technical] {
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
            }
        } else if tableView.restorationIdentifier == "futureTable" {
            if let t = self.variables[future] {
                variableName = self.variableNames[t[indexPath.row]] ?? ""
            }
        } else if tableView.restorationIdentifier == "pastTable" {
            if let t = self.variables[past] {
                variableName = self.variableNames[t[indexPath.row]] ?? ""
            }
        } else if tableView.restorationIdentifier == "healthTable" {
            if let t = self.variables[health] {
                variableName = self.variableNames[t[indexPath.row]] ?? ""
            }
        } else if tableView.restorationIdentifier == "technicalTable" {
            if let t = self.variables[technical] {
                variableName = self.variableNames[t[indexPath.row]] ?? ""
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
    
    @IBAction func technicalWeightChanged(_ sender: Any) {
        self.weightingChanged(self.technical, sender: sender)
    }
    
    private func weightingChanged(_ variable:String, sender:Any){
        if let sender = sender as? UITextField, let value = Double(sender.text!) {
            self.scoreSettings.weightings![variable] = value
            somethingChanged = true
            self.updateTotalWeighting()
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
