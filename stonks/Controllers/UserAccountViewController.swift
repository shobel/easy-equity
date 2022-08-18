//
//  UserAccountViewController.swift
//  stonks
//
//  Created by Samuel Hobel on 7/23/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import UIKit

class UserAccountViewController: UIViewController, ShadowButtonDelegate {

    @IBOutlet var mainView: UIView!
    @IBOutlet weak var userid: UILabel!
    @IBOutlet weak var creditBalanceButton: ShadowButtonView!
    @IBOutlet weak var signOutButton: UIButton!
    
    override func viewDidLoad() {
        self.mainView.addPurpleGradientBackground()
        Dataholder.subscribeForCreditBalanceUpdates(self)
        self.creditBalanceButton.credits.text = String("\(Dataholder.getCreditBalance())")
        self.creditBalanceButton.delegate = self
        self.creditBalanceButton.bgColor = .clear
        userid.text = KeychainItem.currentEmail
        self.signOutButton.layer.borderWidth = 1.0
        self.signOutButton.layer.borderColor = Constants.lightPurple.cgColor
        self.signOutButton.layer.cornerRadius = self.signOutButton.bounds.height / 2.0
        super.viewDidLoad()
    }
    
    @IBAction func signoutButtonTapped(_ sender: Any) {
        NetworkManager.getMyRestApi().signOutAndClearKeychain()
    }
    
    func creditBalanceUpdated() {
        DispatchQueue.main.async {
            self.creditBalanceButton.credits.text = String("\(Dataholder.getCreditBalance())")
        }
    }
    
    func shadowButtonTapped(_ premiumPackage:PremiumPackage?) {
        self.openPurchaseView()
    }
    
    private func openPurchaseView(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let purchaseVC = storyboard.instantiateViewController(withIdentifier: "purchaseCreditsVC") as! PurchaseViewController
        self.present(purchaseVC, animated: true, completion: nil)
    }
    
    @IBAction func pp(_ sender: Any) {
        if let url = URL(string: "https://sites.google.com/view/stoccoon/privacy-policy") {
            UIApplication.shared.open(url)
        }
    }
    @IBAction func tc(_ sender: Any) {
        if let url = URL(string: "https://sites.google.com/view/stoccoon/terms-and-conditions") {
            UIApplication.shared.open(url)
        }
    }
    @IBAction func eula(_ sender: Any) {
        if let url = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
