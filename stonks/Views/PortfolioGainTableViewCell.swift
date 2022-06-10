//
//  PortfolioGainTableViewCell.swift
//  stonks
//
//  Created by Samuel Hobel on 6/5/22.
//  Copyright © 2022 Samuel Hobel. All rights reserved.
//

import UIKit

class PortfolioGainTableViewCell: UITableViewCell {

    @IBOutlet weak var ticker: UILabel!
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var daysToEarnings: UILabel!
    @IBOutlet weak var erImage: UIImageView!
    @IBOutlet weak var buyRating: RatingLabel!
    
    @IBOutlet weak var dayGain: ColoredValueLabel!
    @IBOutlet weak var dayGainPercent: ColoredValueLabel!
    
    @IBOutlet weak var totalGain: ColoredValueLabel!
    @IBOutlet weak var totalGainPercent: ColoredValueLabel!
    
    @IBOutlet weak var currentValue: ColoredValueLabel!
    @IBOutlet weak var numShares: ColoredValueLabel!
    @IBOutlet weak var cbs: ColoredValueLabel!
    @IBOutlet weak var percentPort: ColoredValueLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        let bgColorView = UIView()
        bgColorView.backgroundColor = .clear
        self.selectedBackgroundView = bgColorView    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
