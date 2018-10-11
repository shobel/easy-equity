//
//  RatingLabel.swift
//  stonks
//
//  Created by Samuel Hobel on 10/10/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import UIKit

class RatingLabel: UILabel {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    private func commonInit(){
        //self.layer.borderWidth = 2
        self.layer.cornerRadius = (self.frame.width)/2
        self.layer.masksToBounds = true
    }
    
    public func setRatingColor(buy: Double, hold: Double, sell: Double){
        //self.layer.borderColor = Constants.ratingColors[self.ratingType]?.cgColor
        let green = ((buy/100.0)*2)*255 + ((hold/100.0))*255
        let red = ((sell/100.0)*2)*255 + ((hold/100.0))*255
        self.layer.backgroundColor = UIColor(red: CGFloat(red/255.0), green: CGFloat(green/255.0), blue: 0.0/255.0, alpha: 1.0).cgColor
    }
    
    /*
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.layer.borderWidth = 2
        self.layer.borderColor = Constants.ratingColors[type]?.cgColor
        self.layer.cornerRadius = (self.frame.width)/2 
        self.layer.masksToBounds = true
    }
    */
}
