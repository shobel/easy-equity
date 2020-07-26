//
//  EmailVerificationViewController.swift
//  stonks
//
//  Created by Samuel Hobel on 7/13/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import UIKit
import FirebaseAuth
import TransitionButton

class PasswordResetViewController: UIViewController {

    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var sendResetCodeButton: TransitionButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sendResetCodeButton.layer.cornerRadius = 25
        self.emailInput.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.hideErrorLabel()
    }
    
    @IBAction func sendResetCodeButtonTapped(_ sender: Any) {
        self.sendResetCodeButton.startAnimation()
        let emailValid = GeneralUtility.isValidEmail(emailInput.text!)
        if !emailValid {
            self.sendResetCodeButton.stopAnimation(animationStyle: .shake) {
                self.showErrorLabel("Email address invalid.")
            }
        } else {
            hideErrorLabel()
        }
        if emailValid {
            Auth.auth().sendPasswordReset(withEmail: self.emailInput.text!) { (error) in
                if error != nil {
                    self.sendResetCodeButton.stopAnimation(animationStyle: .shake) {
                        self.showErrorLabel("This email address does not have an account.")
                    }
                } else {
                    self.sendResetCodeButton.stopAnimation()
                    let alert = AlertDisplay.createAlertWithConfirmButton(title: "Password Reset Email Sent", message: "Follow the instructions sent to your email to reset your password", buttonText: "Got it") { (UIAlertAction) in
                        self.dismiss(animated: true, completion: nil)
                    }
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    private func showErrorLabel(_ message:String){
        self.errorLabel.text = message
        self.errorLabel.isHidden = false
    }
    
    private func hideErrorLabel(){
        self.errorLabel.isHidden = true
    }
    
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    */

}
