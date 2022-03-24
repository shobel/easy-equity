//
//  UserAccountViewController.swift
//  stonks
//
//  Created by Samuel Hobel on 7/23/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import UIKit
import Firebase

class UserAccountViewController: UIViewController, ShadowButtonDelegate {

    @IBOutlet weak var userid: UILabel!
    @IBOutlet weak var creditBalanceButton: ShadowButtonView!
    
    override func viewDidLoad() {
        Dataholder.subscribeForCreditBalanceUpdates(self)
        self.creditBalanceButton.credits.text = String("\(Dataholder.getCreditBalance())")
        self.creditBalanceButton.delegate = self
        self.creditBalanceButton.bgColor = Constants.orange
        self.creditBalanceButton.shadColor = UIColor(red: 100.0/255.0, green: 60.0/255.0, blue: 25.0/255.0, alpha: 1.0).cgColor
        userid.text = KeychainItem.currentEmail
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
    @IBAction func buyCredits(_ sender: Any) {
        self.openPurchaseView()
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
