//
//  ShadowButton.swift
//  stonks
//
//  Created by Samuel Hobel on 4/5/21.
//  Copyright © 2021 Samuel Hobel. All rights reserved.
//

import UIKit

class ShadowButton: UIButton {

    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        self.layer.backgroundColor = UIColor.white.cgColor
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        self.layer.shadowOpacity = 0.2
        self.layer.shadowRadius = 4.0
        self.layer.masksToBounds = false
        self.layer.cornerRadius = 10.0
        self.contentEdgeInsets = UIEdgeInsets(top: 10.0, left: 20.0, bottom: 10.0, right: 20.0)
    }
    

}
