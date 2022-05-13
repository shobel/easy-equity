//
//  IndustryCollectionViewCell.swift
//  stonks
//
//  Created by Samuel Hobel on 11/24/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import UIKit

class IndustryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var industryName: UILabel!
    @IBOutlet weak var performance: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 10
    }
    
    public func setPerformance(_ perf: Double){
        self.performance.text = String(format: "%.2f%%", perf*100.0)
        self.backgroundColor = self.getColor(perf)
    }
    
    private func getColor(_ perf: Double) -> UIColor {
        if perf > 0.02 {
            return Constants.bigGreen
        } else if perf > 0.01 {
            return Constants.mediumGreen
        } else if perf > 0.005 {
            return Constants.smallGreen
        } else if perf > -0.005 {
            return Constants.neutralGrey
        } else if perf > -0.01 {
            return Constants.smallRed
        } else if perf > -0.02 {
            return Constants.mediumRed
        } else {
            return Constants.bigRed
        }
    }
}
