//
//  SignupViewController.swift
//  stonks
//
//  Created by Samuel Hobel on 7/13/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import UIKit
import FirebaseAuth
import TransitionButton

class SignupViewController: UIViewController {


    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var registerButton: TransitionButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    private var restAPI:MyRestAPI!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.restAPI = NetworkManager.getMyRestApi()
        emailInput.attributedPlaceholder = NSAttributedString(string: "email address", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        passwordInput.attributedPlaceholder = NSAttributedString(string: "password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        self.emailInput.becomeFirstResponder()
        self.registerButton.layer.cornerRadius = 25

        // Do any additional setup after loading the view.
    }
    
    @IBAction func registerButtonClicked(_ sender: Any) {
        self.registerButton.startAnimation()
        let error = validateFields()
        if error != nil {
            self.registerButton.stopAnimation(animationStyle: .shake, completion: nil)
            showError(error!)
        } else {
            Auth.auth().createUser(withEmail: self.emailInput.text!, password: self.passwordInput.text!) { (result, err) in
                if let err = err {
                    self.showError(err.localizedDescription)
                    self.registerButton.stopAnimation(animationStyle: .shake, completion: nil)
                } else {
                    self.restAPI.createUser(id: Auth.auth().currentUser!.uid, email: self.emailInput.text!) { (JSON) in
                        DispatchQueue.main.async {
                            self.hideError()
                            self.registerButton.stopAnimation(animationStyle: .expand, completion: {
                                self.performSegue(withIdentifier: "toHome", sender: self)
                            })
                        }
                    }
                }
            }
        }
    }
    
    func showError(_ message:String){
        errorLabel.text = message
        errorLabel.isHidden = false
    }
    
    func hideError(){
        errorLabel.text = ""
        errorLabel.isHidden = true
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
