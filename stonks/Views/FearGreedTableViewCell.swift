//
//  FearGreedTableViewCell.swift
//  stonks
//
//  Created by Samuel Hobel on 11/23/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import UIKit
import GaugeKit

class FearGreedTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var gauge: Gauge!
    @IBOutlet weak var indicatorText: UITextView!
    @IBOutlet weak var indicatorString: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
