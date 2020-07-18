//
//  LoginViewController.swift
//  stonks
//
//  Created by Samuel Hobel on 7/12/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import UIKit
import AVKit
import VisualEffectView
import TransitionButton
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var loginButton: TransitionButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    private var restAPI:MyRestAPI!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.restAPI = NetworkManager.getMyRestApi()
        emailInput.attributedPlaceholder = NSAttributedString(string: "email address", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        passwordInput.attributedPlaceholder = NSAttributedString(string: "password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        self.emailInput.becomeFirstResponder()
        self.loginButton.layer.cornerRadius = 25
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.hideError()
    }
    
    @IBAction func loginButtonClicked(_ sender: Any) {
        self.loginButton.startAnimation()
        let error = validateFields()
        if error != nil {
            self.loginButton.stopAnimation(animationStyle: .shake, completion: nil)
            showError(error!)
        } else {
            Auth.auth().signIn(withEmail: self.emailInput.text!, password: self.passwordInput.text!) { (result, err) in
                if err != nil {
                    self.showError("Wrong username or password.")
                    self.loginButton.stopAnimation(animationStyle: .shake, completion: nil)
                } else {
                    self.hideError()
                    self.loginButton.stopAnimation(animationStyle: .expand, completion: {
                        self.performSegue(withIdentifier: "toHome", sender: self)
                    })
                }
            }
        }
    }
    
    private func sendVerificationCode(_ email:String){
        if GeneralUtility.isValidEmail(email){
            print("OK")
        }
    }
    
    func validateFields() -> String? {
        if emailInput.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordInput.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please provide an email address and password."
        }
        if (!GeneralUtility.isPasswordValid(passwordInput.text!)){
            return "Your password must be at least 8 characters."
        }
        return nil
    }
    
    func showError(_ message:String){
        errorLabel.text = message
        errorLabel.isHidden = false
    }
    
    func hideError(){
        errorLabel.text = ""
        errorLabel.isHidden = true
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
