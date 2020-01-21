//
//  NewsViewController.swift
//  stonks
//
//  Created by Samuel Hobel on 9/12/19.
//  Copyright © 2019 Samuel Hobel. All rights reserved.
//

import UIKit

class NewsViewController: UIViewController, StatsVC {

    private var company:Company!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        company = Dataholder.watchlistManager.selectedCompany
    }
    
    func updateData() {
        
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
