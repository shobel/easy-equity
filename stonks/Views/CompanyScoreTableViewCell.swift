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
        
        rank.layer.cornerRadius = (rank.frame.width)/2
        rank.layer.masksToBounds = true
        
        score.layer.cornerRadius = (score.frame.width)/2
        score.layer.masksToBounds = true
        
        cellView.backgroundColor = UIColor.white
//        cellView.layer.borderColor = UIColor.black.cgColor
//        cellView.layer.borderWidth = 1
        cellView.layer.cornerRadius = 8
//        cellView.clipsToBounds = true
        cellView.layer.shadowColor = UIColor.black.cgColor
        cellView.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        cellView.layer.shadowOpacity = 0.2
        cellView.layer.shadowRadius = 2.0
        
    }
    
    public func setData(industryColor: UIColor, rank:Int, industryRank:Int, industryTotal:Int, percentile:Double){
        self.industryContainer.layer.backgroundColor = industryColor.cgColor
        self.score.backgroundColor = self.getScoreTextColor(percentile).withAlphaComponent(0.2)
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
                Dataholder.watchlistManager.addCompany(company: c){
                    self.addedToWatchlist(true)
                }
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
