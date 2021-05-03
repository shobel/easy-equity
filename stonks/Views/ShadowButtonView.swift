//
//  ShadowButtonView.swift
//  stonks
//
//  Created by Samuel Hobel on 5/2/21.
//  Copyright © 2021 Samuel Hobel. All rights reserved.
//

import UIKit

class ShadowButtonView: UIView {

    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        self.layer.cornerRadius = 5.0
        self.clipsToBounds = true
        self.layer.shadowColor = UIColor(red: 25.0/255.0, green: 105.0/255.0, blue: 75.0/255.0, alpha: 1.0).cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.masksToBounds = false

    }
    

}
