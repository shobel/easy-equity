//
//  CustomProgressView.swift
//  stonks
//
//  Created by Samuel Hobel on 8/18/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import UIKit

class CustomProgressView: UIProgressView {

    override func layoutSubviews() {
        super.layoutSubviews()

        let maskLayerPath = UIBezierPath(roundedRect: bounds, cornerRadius: 14.0)
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskLayerPath.cgPath
        layer.mask = maskLayer
    }

}
