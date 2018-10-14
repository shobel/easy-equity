//
//  MarkerView.swift
//  stonks
//
//  Created by Samuel Hobel on 10/11/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import UIKit

class MarkerView: UIView {

    //@IBOutlet var valueLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    private func commonInit(){
        self.layer.cornerRadius = 5
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
