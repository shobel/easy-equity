//
//  Extensions.swift
//  stonks
//
//  Created by Samuel Hobel on 8/27/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func showHomeViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let homeViewController = storyboard.instantiateViewController(withIdentifier: "Landing")
        homeViewController.modalPresentationStyle = .fullScreen
        homeViewController.isModalInPresentation = false
        UIApplication.topViewController()?.present(homeViewController, animated: true, completion: nil)
    }
    
    func showAuthViewController(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let authVC = storyboard.instantiateViewController(withIdentifier: "Auth")
        authVC.isModalInPresentation = false
        authVC.modalPresentationStyle = .fullScreen
        UIApplication.topViewController()?.present(authVC, animated: true, completion: nil)
    }
}

extension UIView {
    func addGradientBackground(){
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [Constants.purple.cgColor, Constants.darkPink.cgColor]
        gradientLayer.frame = self.bounds
        gradientLayer.locations = [0.0, 0.8]
        gradientLayer.startPoint = CGPoint.zero
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    @IBInspectable
    var rotation: Int {
        get {
            return 0
        } set {
            let radians = ((CGFloat.pi) * CGFloat(newValue) / CGFloat(180.0))
            self.transform = CGAffineTransform(rotationAngle: radians)
        }
    }
}

@IBDesignable
class DesignableLabel: UILabel {
}

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.windows.first!.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}

extension UILabel {
    func uiLabelTextShadow(){
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.rasterizationScale = UIScreen.main.scale
        self.layer.shadowRadius = 1.0
        self.layer.shadowOpacity = 0.5
   }
}

extension Date {

    func timeAgoSinceDate() -> String {
        // From Time
        let fromDate = self

        // To Time
        let toDate = Date()

        // Estimation
        // Year
        if let interval = Calendar.current.dateComponents([.year], from: fromDate, to: toDate).year, interval > 0  {
            return interval == 1 ? "\(interval)" + " " + "year ago" : "\(interval)" + " " + "years ago"
        }

        // Month
        if let interval = Calendar.current.dateComponents([.month], from: fromDate, to: toDate).month, interval > 0  {
            return interval == 1 ? "\(interval)" + " " + "month ago" : "\(interval)" + " " + "months ago"
        }

        // Day
        if let interval = Calendar.current.dateComponents([.day], from: fromDate, to: toDate).day, interval > 0  {
            return interval == 1 ? "\(interval)" + " " + "day ago" : "\(interval)" + " " + "days ago"
        }

        // Hours
        if let interval = Calendar.current.dateComponents([.hour], from: fromDate, to: toDate).hour, interval > 0 {
            return interval == 1 ? "\(interval)" + " " + "hour ago" : "\(interval)" + " " + "hours ago"
        }

        // Minute
        if let interval = Calendar.current.dateComponents([.minute], from: fromDate, to: toDate).minute, interval > 0 {
            return interval == 1 ? "\(interval)" + " " + "minute ago" : "\(interval)" + " " + "minutes ago"
        }
        return "a moment ago"
    }
    
    func interval(ofComponent comp: Calendar.Component, fromDate date: Date) -> Int {

           let currentCalendar = Calendar.current

           guard let start = currentCalendar.ordinality(of: comp, in: .era, for: date) else { return 0 }
           guard let end = currentCalendar.ordinality(of: comp, in: .era, for: self) else { return 0 }

           return end - start
       }
}
