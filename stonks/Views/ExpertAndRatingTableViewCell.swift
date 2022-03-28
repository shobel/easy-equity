//
//  ExpertAndRatingTableViewCell.swift
//  stonks
//
//  Created by Samuel Hobel on 5/13/21.
//  Copyright © 2021 Samuel Hobel. All rights reserved.
//

import UIKit
import Cosmos

class ExpertAndRatingTableViewCell: UITableViewCell {

    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var rankLabelContainer: UIView!
    @IBOutlet weak var analystNameLabel: UILabel!
    @IBOutlet weak var typeAndFirmLabel: UILabel!
    @IBOutlet weak var overallSuccessRate: CircularProgressView!
    @IBOutlet weak var overallReturn: CircularProgressView!
    @IBOutlet weak var stockSuccessRate: CircularProgressView!
    @IBOutlet weak var stockReturn: CircularProgressView!
    @IBOutlet weak var priceTargetLabel: UILabel!
    @IBOutlet weak var ptPercentOff: UILabel!
    @IBOutlet weak var positionLabelContainer: UIView!
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var date: UILabel!
    
    @IBOutlet weak var overallNumRatings: UILabel!
    @IBOutlet weak var stockNumRatings: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.rankLabelContainer.layer.cornerRadius = 5
        self.positionLabelContainer.layer.cornerRadius = 5
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
