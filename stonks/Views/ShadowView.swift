//
//  ShadowView.swift
//  stonks
//
//  Created by Samuel Hobel on 2/23/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import UIKit

class ShadowView: UIView {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layoutView()
    }
    
    func layoutView() {
//       layer.backgroundColor = UIColor.clear.cgColor
//       layer.shadowColor = UIColor.white.cgColor
//       layer.shadowOffset = CGSize(width: 0, height: 1.0)
//       layer.shadowOpacity = 0.2
//       layer.shadowRadius = 4.0
    }
    
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        self.backgroundColor = .clear
    }
    

}
