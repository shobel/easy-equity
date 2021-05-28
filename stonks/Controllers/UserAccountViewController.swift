//
//  UserAccountViewController.swift
//  stonks
//
//  Created by Samuel Hobel on 7/23/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import UIKit
import Firebase

class UserAccountViewController: UIViewController {

    @IBOutlet weak var userid: UILabel!
    
    override func viewDidLoad() {
        userid.text = KeychainItem.currentEmail
        super.viewDidLoad()
    }
    
    @IBAction func signoutButtonTapped(_ sender: Any) {
        NetworkManager.getMyRestApi().signOutAndClearKeychain()
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
