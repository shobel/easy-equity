//
//  CompanyScoreTableViewCell.swift
//  stonks
//
//  Created by Samuel Hobel on 10/21/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import UIKit

class CompanyScoreTableViewCell: UITableViewCell {

    @IBOutlet weak var symbol: UILabel!
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var rank: UILabel!
    @IBOutlet weak var score: UILabel!
    @IBOutlet weak var industryContainer: UIView!
    @IBOutlet weak var industry: UILabel!
    @IBOutlet weak var watchlistButton: UIButton!

    @IBOutlet weak var cellView: UIView!
    
    private var company:Company?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        industryContainer.layer.cornerRadius = 10
        industryContainer.layer.backgroundColor = UIColor.gray.cgColor
        
        rank.layer.cornerRadius = (rank.frame.height)/2
        rank.layer.masksToBounds = true
        rank.adjustsFontSizeToFitWidth = true
        rank.minimumScaleFactor = 0.5
        
        score.layer.cornerRadius = (score.frame.width)/2
        score.layer.masksToBounds = true
        
        cellView.layer.cornerRadius = 8
    }
    
    public func setData(industryColor: UIColor, rank:Int, industryRank:Int, industryTotal:Int, percentile:Double){
        self.industryContainer.layer.backgroundColor = industryColor.withAlphaComponent(0.5).cgColor
//        self.score.backgroundColor = self.getScoreTextColor(percentile).withAlphaComponent(0.2)
        self.score.textColor = self.getScoreTextColor(percentile)
        self.rank.backgroundColor = self.getScoreTextColor(percentile).withAlphaComponent(0.2)
        self.rank.textColor = self.getScoreTextColor(percentile)
        
        self.company = Company(symbol: self.symbol.text!, fullName: self.companyName.text!)
    }

    @IBAction func watchlistButtonAction(_ sender: Any) {
        if let c = self.company {
            if (Dataholder.watchlistManager.getWatchlist().contains(c)) {
                Dataholder.watchlistManager.removeCompany(company: c){
                    self.addedToWatchlist(false)
                }
            } else {
                Dataholder.watchlistManager.addCompany(company: c){ added in
                    if added {
                        self.addedToWatchlist(true)
                    } else {
                        AlertDisplay.showAlert("Error", message: "Watchlist limit reached")
                    }
                }
            }
        }
    }
    
    public func addedToWatchlist(_ added:Bool) {
        DispatchQueue.main.async {
            if added {
                self.watchlistButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
                self.watchlistButton.tintColor = Constants.veryLightPurple
            } else {
                self.watchlistButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
                self.watchlistButton.tintColor = .white
            }
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func getScoreTextColor(_ val:Double) -> UIColor {
        let blue:CGFloat = 0.0
        var red:CGFloat = 0.0
        var green:CGFloat = 0.0
        if val <= 0.5 {
            red = 218.0
            green = CGFloat((val/0.5) * 218.0)
        } else {
            green = 218.0
            red = CGFloat(218.0 - ((val - 0.5)/0.5) * 218.0)
        }
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1.0)
    }

}
