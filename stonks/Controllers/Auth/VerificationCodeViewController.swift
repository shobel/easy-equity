//
//  VerificationCodeViewController.swift
//  stonks
//
//  Created by Samuel Hobel on 7/13/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import UIKit
import FirebaseAuth

class VerificationCodeViewController: UIViewController {

    @IBOutlet weak var codeInput: UITextField!
    @IBOutlet weak var resendButton: UIButton!
    
    public var email:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func resendButtonClicked(_ sender: Any) {
        Auth.auth().sendPasswordReset(withEmail: self.email!) { (error) in
            
        }
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
