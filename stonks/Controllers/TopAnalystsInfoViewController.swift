//
//  TopAnalystsInfoViewController.swift
//  stonks
//
//  Created by Samuel Hobel on 3/30/22.
//  Copyright © 2022 Samuel Hobel. All rights reserved.
//

import UIKit

class TopAnalystsInfoViewController: UIViewController {

    @IBOutlet var mainView: UIView!
    @IBOutlet weak var progressView: CircularProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainView.addPurpleGradientBackground()
        self.progressView.setProgressNoLabel(CGFloat(0.50))
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
