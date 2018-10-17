//
//  RatingLabel.swift
//  stonks
//
//  Created by Samuel Hobel on 10/10/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import UIKit

class RatingLabel: UILabel {
    
    //color range from red to yellow to green based on the 1-10 "bullish" score
    var colors:[UIColor] = [
        UIColor(red: 237.0/255.0, green: 50.0/255.0, blue: 49.0/255.0, alpha: 1.0),
        UIColor(red: 237.0/255.0, green: 85.0/255.0, blue: 49.0/255.0, alpha: 1.0),
        UIColor(red: 237.0/255.0, green: 120.0/255.0, blue: 49.0/255.0, alpha: 1.0),
        UIColor(red: 237.0/255.0, green: 155.0/255.0, blue: 49.0/255.0, alpha: 1.0),
        UIColor(red: 237.0/255.0, green: 190.0/255.0, blue: 49.0/255.0, alpha: 1.0),
        UIColor(red: 237.0/255.0, green: 237.0/255.0, blue: 49.0/255.0, alpha: 1.0),
        UIColor(red: 215.0/255.0, green: 237.0/255.0, blue: 49.0/255.0, alpha: 1.0),
        UIColor(red: 200.0/255.0, green: 237.0/255.0, blue: 49.0/255.0, alpha: 1.0),
        UIColor(red: 180.0/255.0, green: 237.0/255.0, blue: 49.0/255.0, alpha: 1.0),
        UIColor(red: 150.0/255.0, green: 237.0/255.0, blue: 49.0/255.0, alpha: 1.0),
        UIColor(red: 120.0/255.0, green: 237.0/255.0, blue: 49.0/255.0, alpha: 1.0)
    ]
    
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
    
    public func setRatingColor(score: Double){
        if (score == -1){
            self.backgroundColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0)
        } else {
            let scoreIndex = Int(score.rounded())
            self.backgroundColor = colors[scoreIndex]
        }
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
