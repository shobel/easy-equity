//
//  StockDetailsSummaryView.swift
//  stonks
//
//  Created by Samuel Hobel on 10/9/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import UIKit

class StockDetailsSummaryView: UIStackView {

    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var priceChangeAndPercent: ColoredPricePercentLabel!
    @IBOutlet var ahPriceChangeAndPercent: ColoredPricePercentLabel!
    
    @IBOutlet var sectorLabel: UILabel!
    @IBOutlet var mktCapLabel: UILabel!
    @IBOutlet var ytdChange: UILabel!
    @IBOutlet var yrHighChange: UILabel!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
