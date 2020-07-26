//
//  AlertDisplay.swift
//  stonks
//
//  Created by Samuel Hobel on 7/13/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import Foundation
import UIKit

struct AlertDisplay {
    
    public static func createAlertWithConfirmButton(title:String, message:String, buttonText:String, handler: @escaping (UIAlertAction) -> Void) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: handler))
        return alert
    }
}
