//
//  HelpInfoViewController.swift
//  stonks
//
//  Created by Samuel Hobel on 5/17/22.
//  Copyright © 2022 Samuel Hobel. All rights reserved.
//

import UIKit

class HelpInfoViewController: UIViewController {

    @IBOutlet var mainView: UIView!
    @IBOutlet weak var header: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainView.addPurpleGradientBackground()
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
