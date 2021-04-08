//
//  CompanySearchSimpleTableViewCell.swift
//  stonks
//
//  Created by Samuel Hobel on 1/20/21.
//  Copyright © 2021 Samuel Hobel. All rights reserved.
//

import UIKit

class CompanySearchSimpleTableViewCell: UITableViewCell {

    @IBOutlet weak var symbol: UILabel!
    @IBOutlet weak var companyName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
