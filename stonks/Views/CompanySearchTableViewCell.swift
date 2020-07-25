//
//  CompanySearchTableViewCell.swift
//  stonks
//
//  Created by Samuel Hobel on 7/22/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import UIKit

class CompanySearchTableViewCell: UITableViewCell {

    @IBOutlet weak var symbol: UILabel!
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var watchlistButton: UIButton!
    public var parentVC:CompanySearchVC?
    public var company:Company!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func watchlistButtonTapped(_ sender: Any) {
        self.parentVC?.loadingStarted()
        if (Dataholder.watchlistManager.getWatchlist().contains(self.company)) {
            Dataholder.watchlistManager.removeCompany(company: self.company){
                self.addedToWatchlist(false)
                self.parentVC?.loadingFinished()
            }
        } else {
            Dataholder.watchlistManager.addCompany(company: self.company){
                self.addedToWatchlist(true)
                self.parentVC?.loadingFinished()
            }
        }
    }
    
    public func addedToWatchlist(_ added:Bool) {
        DispatchQueue.main.async {
            if added {
                self.watchlistButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
                self.watchlistButton.tintColor = Constants.darkPink
            } else {
                self.watchlistButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
                self.watchlistButton.tintColor = Constants.darkGrey
            }
        }
    }
}