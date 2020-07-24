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

    @IBOutlet weak var emailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailLabel.text = Auth.auth().currentUser?.email
    }
    
    @IBAction func signoutButtonTapped(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            NetworkManager.getMyRestApi().setToken(token: "")
        } catch let err {
            print(err)
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
