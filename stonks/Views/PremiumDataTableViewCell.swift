//
//  PremiumDataTableViewCell.swift
//  stonks
//
//  Created by Samuel Hobel on 5/25/22.
//  Copyright © 2022 Samuel Hobel. All rights reserved.
//

import UIKit

class PremiumDataTableViewCell: UITableViewCell {

    @IBOutlet weak var promoImage: UIImageView!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var dataTitle: UILabel!
    @IBOutlet weak var purchasedContainer: UIView!
    @IBOutlet weak var purchasedDate: UILabel!
    @IBOutlet weak var dataDescription: UILabel!
    @IBOutlet weak var costContainer: UIView!
    @IBOutlet weak var costLabel: ShadowButtonView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        self.backgroundColor = Constants.themeDarkBlue
        self.costContainer.layer.cornerRadius = 10.0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = 10.0
//        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
