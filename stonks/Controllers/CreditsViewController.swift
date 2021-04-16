//
//  CreditsViewController.swift
//  stonks
//
//  Created by Samuel Hobel on 4/11/21.
//  Copyright © 2021 Samuel Hobel. All rights reserved.
//

import UIKit
import SPStorkController

class CreditsViewController: UIViewController {

    @IBOutlet weak var creditsValue: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func getMoreCredits(_ sender: Any) {
        let pvc = self.presentingViewController

        self.dismiss(animated: true, completion: {
            let vc = self.storyboard?.instantiateViewController(identifier: "purchaseCreditsVC")
            pvc?.present(vc!, animated: true, completion: nil)
        })
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    

    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    */
        

}
