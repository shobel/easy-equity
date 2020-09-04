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
