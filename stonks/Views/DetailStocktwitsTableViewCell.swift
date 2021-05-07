//
//  DetailStocktwitsTableViewCell.swift
//  stonks
//
//  Created by Samuel Hobel on 10/27/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import UIKit

class DetailStocktwitsTableViewCell: UITableViewCell {

    @IBOutlet weak var username: UIButton!
    @IBOutlet weak var message: UITextView!
    @IBOutlet weak var bullbear: UILabel!
    @IBOutlet weak var timeButton: UIButton!
    public var id:Int?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.message.backgroundColor = .white
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func timeTapped(_ sender: Any) {
        if let id = self.id, let username = username.title(for: .normal){
            if let url = URL(string: String("http://www.stocktwits.com/\(username)/message/\(id)")) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    @IBAction func usernameTapped(_ sender: Any) {
        if let username = username.title(for: .normal) {
            if let url = URL(string: String("http://www.stocktwits.com/\(username)")) {
                UIApplication.shared.open(url)
            }
        }
    }
}
