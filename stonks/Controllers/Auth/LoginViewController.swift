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
import FCAlertView

class LoginViewController: UIViewController, UITextFieldDelegate, FCAlertViewDelegate {
    
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var loginButton: TransitionButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailInput.attributedPlaceholder = NSAttributedString(string: "email address", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        passwordInput.attributedPlaceholder = NSAttributedString(string: "password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        self.emailInput.becomeFirstResponder()
        self.emailInput.keyboardType = .emailAddress
        self.emailInput.delegate = self
        self.passwordInput.delegate = self
        
        loginButton.layer.cornerRadius = 25
        loginButton.layer.borderColor = UIColor.white.cgColor
        loginButton.layer.borderWidth = CGFloat(1)
        closeButton.imageView?.layer.transform = CATransform3DMakeScale(1.5,1.5,1.5)

        self.view.addPurpleGradientBackground()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.hideError()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
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
                    let errorCode:AuthErrorCode = AuthErrorCode(_nsError: err! as NSError)
                    switch errorCode.code {
                        case.wrongPassword:
                            self.showError("Wrong username or password.")
                            self.loginButton.stopAnimation(animationStyle: .shake, completion: nil)
                            break
                        case.userNotFound:
                            self.emailInput.resignFirstResponder()
                            self.passwordInput.resignFirstResponder()
                            self.askIfSignUp()
                            break
                        default:
                            break
                    }
                } else {
                    self.getIdTokenAndLogin(createUser:false)
                }
            }
        }
    }
    
    private func saveUserToKeychain(_ idtoken:String) throws -> Void {
        if let email = Auth.auth().currentUser?.email {
            try KeychainItem(service: Bundle.main.bundleIdentifier!, account: "userEmail").saveItem(email)
        }
        try KeychainItem(service: Bundle.main.bundleIdentifier!, account: "userIdentifier").saveItem(idtoken)
        try KeychainItem(service: Bundle.main.bundleIdentifier!, account: "refreshToken").saveItem(Auth.auth().currentUser?.refreshToken ?? "")
    }
    
    private func signUp(){
        if self.emailInput.text != nil && self.passwordInput.text != nil {
            self.loginButton.startAnimation()
            Auth.auth().createUser(withEmail: self.emailInput.text!, password: self.passwordInput.text!) { res, error in
                if error == nil {
                    Auth.auth().signIn(withEmail: self.emailInput.text!, password: self.passwordInput.text!) { (result, err) in
                        if err == nil {
                            self.getIdTokenAndLogin(createUser:true)
                        }
                    }
                } else {
                    self.showError("Error creating account")
                }
            }
        }
    }
    
    private func getIdTokenAndLogin(createUser:Bool){
        Auth.auth().currentUser?.getIDToken(completion: { str, err in
            if str != nil {
                do {
                    try self.saveUserToKeychain(str!)
                } catch {
                    print("oops")
                }
                self.hideError()
                if createUser {
                    NetworkManager.getMyRestApi().createUser(self.emailInput.text!) { () in
                    }
                }
                self.loginButton.stopAnimation(animationStyle: .expand, completion: {
                    self.performSegue(withIdentifier: "toHome", sender: self)
                })
            }
        })
    }
    
    func fcAlertViewDismissed(_ alertView: FCAlertView!) {
        self.loginButton.stopAnimation(animationStyle: .normal, completion: nil)
    }
    
    private func askIfSignUp(){
        let message = "The username " + self.emailInput.text! + " is available. Would you like to sign up for an account with this email?"
        let alert = FCAlertView()
        alert.delegate = self
        alert.doneActionBlock {
            self.signUp()
        }
        alert.alertBackgroundColor = Constants.themePurple
        alert.titleColor = .white
        alert.subTitleColor = .white
        alert.colorScheme = Constants.lightPurple
        alert.doneButtonTitleColor = .white
        alert.secondButtonTitleColor = .darkGray
        alert.firstButtonTitleColor = .darkGray
        alert.dismissOnOutsideTouch = true
        alert.detachButtons = true
        alert.showAlert(inView: self,
                        withTitle: "Sign Up?",
                        withSubtitle: message,
                        withCustomImage: UIImage(systemName: "questionmark.circle"),
                        withDoneButtonTitle: "Yes",
                        andButtons: ["No"])
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
    
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
