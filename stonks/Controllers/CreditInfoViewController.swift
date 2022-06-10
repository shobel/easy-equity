//
//  CreditInfoViewController.swift
//  stonks
//
//  Created by Samuel Hobel on 3/29/22.
//  Copyright © 2022 Samuel Hobel. All rights reserved.
//

import UIKit

class CreditInfoViewController: UIViewController {

    @IBOutlet weak var creditBalanceButton: ShadowButtonView!
    @IBOutlet weak var spendCreditsButton: ShadowButtonView!
    @IBOutlet var mainView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainView.addPurpleGradientBackground()
        self.creditBalanceButton.credits.text = "500"
        self.creditBalanceButton.bgColor = .clear
        self.spendCreditsButton.credits.text = "10"
        self.spendCreditsButton.bgColor = Constants.green
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
