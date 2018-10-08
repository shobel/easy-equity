//
//  GradientButton.swift
//  stonks
//
//  Created by Samuel Hobel on 10/7/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import UIKit

class GradientButton: UIButton {

    override func draw(_ rect: CGRect) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [Constants.c2.cgColor, Constants.c1.cgColor]
        gradientLayer.frame = self.bounds
        gradientLayer.locations = [0.0, 0.8]
        gradientLayer.startPoint = CGPoint.zero
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}
