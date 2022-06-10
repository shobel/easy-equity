//
//  PurchaseHistoryTableViewCell.swift
//  stonks
//
//  Created by Samuel Hobel on 12/1/21.
//  Copyright © 2021 Samuel Hobel. All rights reserved.
//

import UIKit

class PurchaseHistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var transactionId: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var supportButton: UIButton!
    @IBOutlet weak var status: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.layer.backgroundColor = UIColor.clear.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
