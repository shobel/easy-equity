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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.creditBalanceButton.credits.text = "500"
        self.creditBalanceButton.bgColor = Constants.orange
        self.creditBalanceButton.shadColor = UIColor(red: 100.0/255.0, green: 60.0/255.0, blue: 25.0/255.0, alpha: 1.0).cgColor
        self.spendCreditsButton.credits.text = "10"
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
