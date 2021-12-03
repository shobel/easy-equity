//
//  PurchaseHistoryViewController.swift
//  stonks
//
//  Created by Samuel Hobel on 11/30/21.
//  Copyright © 2021 Samuel Hobel. All rights reserved.
//

import UIKit

class PurchaseHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var receipts:[Receipt] = []
    
    @IBOutlet weak var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableview.delegate = self
        self.tableview.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NetworkManager.getMyRestApi().getReceiptsForCurrentUser { receipts in
            self.receipts = receipts
            self.receipts = self.receipts.sorted(by: { $0.timestamp! > $1.timestamp! })
            DispatchQueue.main.async {
                self.tableview.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.receipts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableview.dequeueReusableCell(withIdentifier: "purchaseHistoryCell") as! PurchaseHistoryTableViewCell
        let receipt:Receipt = self.receipts[indexPath.row]
        cell.status.text = receipt.status ?? "unknown"
        cell.transactionId.text = "id: " + (receipt.transactionid ?? "unknown")
        cell.date.text = GeneralUtility.timestampToDateString(receipt.timestamp! / 1000)
        let amount:Double = receipt.product?.usd ?? 0.0
        cell.amount.text = String(format: "$%.2f", amount)
        return cell
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
