//
//  PremiumHistoryTableViewCell.swift
//  stonks
//
//  Created by Samuel Hobel on 12/3/21.
//  Copyright © 2021 Samuel Hobel. All rights reserved.
//

import UIKit

class PremiumHistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var transactionId: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var symbol: UILabel!
    @IBOutlet weak var credits: UILabel!
    @IBOutlet weak var packageName: UILabel!
    @IBOutlet weak var supportButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

//        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    }

}
