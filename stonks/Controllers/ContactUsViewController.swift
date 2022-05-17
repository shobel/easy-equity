//
//  ContactUsViewController.swift
//  stonks
//
//  Created by Samuel Hobel on 2/15/22.
//  Copyright © 2022 Samuel Hobel. All rights reserved.
//

import UIKit
import FCAlertView

class ContactUsViewController: UIViewController, UITextViewDelegate {

    @IBOutlet var mainView: UIView!
    @IBOutlet weak var message: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var charCount: UILabel!
    @IBOutlet weak var email: UITextField!
        
    private var transactionId:String?
    private var placeholderText:String = "Write your question/comment/issue here"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainView.addPurpleGradientBackground()
        self.email.attributedPlaceholder = NSAttributedString(
            string: "email address",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        self.email.backgroundColor = .white
        self.message.delegate = self
        self.charCount.text = ""
        self.message.textColor = UIColor.lightGray
        self.message.font = UIFont(name: "System", size: 18)
        self.message.layer.cornerRadius = 5
        self.message.backgroundColor = .white
        NetworkManager.getMyRestApi().getEmailFromFirstUserIssue { email in
            DispatchQueue.main.async {
                if email != nil {
                    self.email.text = email
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if self.transactionId != nil {
            self.message.text = "\n\nTransactionId: " + self.transactionId!
        }
    }
    
    public func setTransactionId(_ id:String) {
        self.transactionId = id
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == self.placeholderText {
            textView.text = ""
        }
        textView.textColor = UIColor.black
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = self.placeholderText
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.charCount.text = String(textView.text.count) + " characters"
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.message.endEditing(true)
        self.email.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    @IBAction func sendButtonClicked(_ sender: Any) {
        if message.text == nil{
            self.showErrorAlert("You must type something into the message box")
            return
        }
        if message.text.count < 100 {
            self.showErrorAlert("Please type at least 100 characters in your message")
            return
        }
        if self.email.text == nil || !GeneralUtility.validateEmailAddress(self.email.text ?? "") {
            self.showErrorAlert("Please provide a valid email address")
            return
        }
        self.sendButton.configuration?.showsActivityIndicator = true
        NetworkManager.getMyRestApi().addUserIssue(message: self.message.text, email: self.email.text!){
            DispatchQueue.main.async {
                self.showSuccessAlert("Message sent")
                self.sendButton.configuration?.showsActivityIndicator = false
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func showErrorAlert(_ error:String){
        let message = String("\(error).")
        let alert = FCAlertView()
        alert.alertBackgroundColor = Constants.themePurple
        alert.titleColor = .white
        alert.subTitleColor = .white
        alert.doneButtonTitleColor = .white
        alert.secondButtonTitleColor = .darkGray
        alert.firstButtonTitleColor = .darkGray
        alert.colorScheme = Constants.darkPink
        alert.dismissOnOutsideTouch = true
        alert.detachButtons = true
        alert.showAlert(inView: self,
                        withTitle: "Error",
                        withSubtitle: message,
                        withCustomImage: UIImage(systemName: "exclamationmark.triangle.fill"),
                        withDoneButtonTitle: "Ok", andButtons: nil)
    }
    
    func showSuccessAlert(_ m:String){
        let message = String("\(m).")
        let alert = FCAlertView()
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
                        withTitle: "Sent",
                        withSubtitle: message,
                        withCustomImage: UIImage(systemName: "checkmark"),
                        withDoneButtonTitle: nil, andButtons: nil)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
