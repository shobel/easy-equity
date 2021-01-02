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
        self.performance.text = String(perf)
        self.backgroundColor = self.getColor(perf)
    }
    
    private func getColor(_ perf: Double) -> UIColor {
        if perf > 0.03 {
            return Constants.bigGreen
        } else if perf > 0.02 {
            return Constants.mediumGreen
        } else if perf > 0.01 {
            return Constants.smallGreen
        } else if perf > -0.01 {
            return Constants.neutralGrey
        } else if perf > -0.02 {
            return Constants.smallRed
        } else if perf > -0.03 {
            return Constants.mediumRed
        } else {
            return Constants.bigRed
        }
    }
}
