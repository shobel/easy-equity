//
//  CardView.swift
//  stonks
//
//  Created by Samuel Hobel on 2/22/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import UIKit

class CardView: UIView {

    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
        layoutView()
    }

    func layoutView() {
        layer.cornerRadius = 10
        layer.masksToBounds = true
    }
    
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
//    override func draw(_ rect: CGRect) {
//        self.layer.backgroundColor = UIColor.yellow.cgColor
//    }
    

}
