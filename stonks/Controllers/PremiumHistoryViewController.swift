//
//  PremiumHistoryViewController.swift
//  stonks
//
//  Created by Samuel Hobel on 12/3/21.
//  Copyright © 2021 Samuel Hobel. All rights reserved.
//

import UIKit

class PremiumHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableview: UITableView!
    private var transactions:[PremiumTransaction] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableview.tableFooterView = UIView() 
        self.tableview.delegate = self
        self.tableview.dataSource = self
        self.updateData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.updateData()
    }
    
    private func updateData(){
        NetworkManager.getMyRestApi().getPremiumTransactionsForCurrentUser() { transactions in
            self.transactions = transactions
            self.transactions = self.transactions.sorted(by: { $0.timestamp! > $1.timestamp! })
            DispatchQueue.main.async {
                self.tableview.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableview.dequeueReusableCell(withIdentifier: "premiumHistoryCell") as! PremiumHistoryTableViewCell
        let transaction:PremiumTransaction = self.transactions[indexPath.row]
        cell.packageName.text = Constants.premiumPackageNames[transaction.packageid!]
        cell.symbol.text = transaction.symbol ?? ""
        cell.date.text = GeneralUtility.timestampToDateString(transaction.timestamp! / 1000)
        let credits:Int = transaction.credits ?? 0
        cell.credits.text = String(credits)
        cell.transactionId.text = "id: " + String(transaction.timestamp!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
