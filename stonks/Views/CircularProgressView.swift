//
//  CircularProgressView.swift
//  stonks
//
//  Created by Samuel Hobel on 8/20/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import UIKit

@IBDesignable class CircularProgressView: UIView {
    private var mainColor: UIColor = Constants.veryLightGrey
    private var forgroundColor: UIColor = Constants.green
    private var backLayerWidth: CGFloat = 10.0
    private var foreLayerWidth: CGFloat = 6.0
    private var progress: CGFloat = 0.0
    
    lazy var backLayer: CAShapeLayer? = {
        let layer = CAShapeLayer()
        layer.strokeColor = mainColor.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = backLayerWidth
        return layer
    }()
    
    lazy var foreLayer: CAShapeLayer? = {
        let layer = CAShapeLayer()
        layer.strokeColor = forgroundColor.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = foreLayerWidth
        layer.lineCap = .round
        return layer
    }()
    
    lazy var progressValueLabel: UILabel? = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        label.textAlignment = .center
        label.textColor = .darkGray
        label.font = UIFont(name: "Futura-bold", size: 14.0)
        label.text = "Test"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.layer.addSublayer(self.backLayer!)
        self.layer.addSublayer(self.foreLayer!)
        self.addSubview(self.progressValueLabel!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = .clear
        self.layer.addSublayer(self.backLayer!)
        self.layer.addSublayer(self.foreLayer!)
        self.addSubview(self.progressValueLabel!)
    }
    
    public func addAnimation() {
        let progressAnimation = CABasicAnimation(keyPath: "strokeEnd")
        progressAnimation.toValue = 1
        progressAnimation.duration = 0.6
        progressAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        progressAnimation.fillMode = CAMediaTimingFillMode.forwards
        progressAnimation.isRemovedOnCompletion = false
        self.foreLayer!.add(progressAnimation, forKey: "progress")
    }
    
    public func customize(backColor: UIColor, progressColor: UIColor, backWidth: CGFloat, progressWidth: CGFloat, progressValue: CGFloat) {
        mainColor = backColor
        forgroundColor = progressColor
        backLayerWidth = backWidth
        foreLayerWidth = progressWidth
        progress = progressValue
    }
    
    override func awakeFromNib() {
    }
    
    public func setProgress(_ progress: CGFloat) {
        var p = progress
        if p < 0 {
            p = 0
        }
        if self.progress != p {
            self.progressValueLabel?.text = String(Int((p*100).rounded())) + "%"
            self.progress = p
            self.progressValueLabel!.sizeToFit()
            self.progressValueLabel!.center = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
            self.addAnimation()
            self.setNeedsDisplay()
        }
    }
    
    public func setProgressAndLabel(_ progress: CGFloat, label:String) {
        var p = progress
        if p < 0 {
            p = 0
        }
        if self.progress != p || self.progressValueLabel?.text != label {
            self.progressValueLabel?.text = label
            self.progress = p
            self.progressValueLabel!.sizeToFit()
            self.progressValueLabel!.center = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
            self.addAnimation()
            self.setNeedsDisplay()
        }
    }
    
    public func setProgressColor(_ color:UIColor){
        self.forgroundColor = color
    }
    
    override func draw(_ rect: CGRect) {
        self.backLayer?.frame = self.bounds.inset(by: UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1))
        self.foreLayer?.frame = self.bounds.inset(by: UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1))
        self.backLayer?.strokeColor = mainColor.cgColor
        self.foreLayer?.strokeColor = forgroundColor.cgColor

        let circle = UIBezierPath.init(ovalIn: self.backLayer!.bounds)
        self.backLayer?.path = circle.cgPath

        let center = CGPoint.init(x: self.foreLayer!.frame.size.width / 2,
                                  y: self.foreLayer!.frame.size.height / 2)
        let start = 0 - CGFloat(Double.pi / 2)
        let end = CGFloat(Double.pi) * 2 * progress - CGFloat(Double.pi / 2)
        let arc = UIBezierPath(arcCenter: center,
                                    radius: self.foreLayer!.frame.size.width / 2,
                                    startAngle: start, endAngle: end, clockwise: true)
        self.foreLayer!.path = arc.cgPath
        self.foreLayer?.strokeEnd = 0
        
        //self.addAnimation()
    }
}
