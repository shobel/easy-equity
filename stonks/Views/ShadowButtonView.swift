//
//  ShadowButtonView.swift
//  stonks
//
//  Created by Samuel Hobel on 5/2/21.
//  Copyright © 2021 Samuel Hobel. All rights reserved.
//

import UIKit

class ShadowButtonView: UIView {

    @IBOutlet var view: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var credits: UILabel!
    @IBOutlet weak var width: NSLayoutConstraint!
    
    public var delegate:PremiumViewController?
    public var premiumPackage:PremiumPackage?
    
    let nibName = "ShadowButtonView"
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit() {
        guard let view = loadViewFromNib() else { return }
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    func loadViewFromNib() -> UIView? {
        let nib = UINib(nibName: nibName, bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        self.delegate?.buyUpdateButtonTapped(self.premiumPackage)
    }
    
    override func draw(_ rect:CGRect) {
        self.containerView.layer.cornerRadius = 5.0
        self.containerView.clipsToBounds = true
        
        self.shadowView.layer.shadowColor = UIColor(red: 25.0/255.0, green: 105.0/255.0, blue: 75.0/255.0, alpha: 1.0).cgColor
        self.shadowView.layer.cornerRadius = 6.0
        self.shadowView.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        self.shadowView.layer.shadowOpacity = 1.0
        self.shadowView.layer.shadowRadius = 0.0
        self.shadowView.layer.masksToBounds = false

    }
    

}
