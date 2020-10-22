//
//  CompanyScoreTableViewCell.swift
//  stonks
//
//  Created by Samuel Hobel on 10/21/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import UIKit

class CompanyScoreTableViewCell: UITableViewCell {

    @IBOutlet weak var symbol: UILabel!
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var score: RatingLabel!
    @IBOutlet weak var percentChange: UILabel!
    @IBOutlet weak var watchlistButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func watchlistButtonAction(_ sender: Any) {
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
