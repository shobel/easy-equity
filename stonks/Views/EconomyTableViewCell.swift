//
//  EconomyTableViewCell.swift
//  stonks
//
//  Created by Samuel Hobel on 11/25/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import UIKit

class EconomyTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var latestValue: UILabel!
    @IBOutlet weak var lineChart: SimplestLineChart!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
