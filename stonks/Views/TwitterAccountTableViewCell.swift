//
//  TwitterAccountTableViewCell.swift
//  stonks
//
//  Created by Samuel Hobel on 4/3/22.
//  Copyright © 2022 Samuel Hobel. All rights reserved.
//

import UIKit

class TwitterAccountTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var imageUrl: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var following: UILabel!
    @IBOutlet weak var followers: UILabel!
    @IBOutlet weak var tweetCount: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var nosymbols: UILabel!
    
    var parentVC:TwitterAccountsViewController?
    var cashtags:[Cashtag] = [] {
        didSet {
            self.nosymbols.isHidden = cashtags.count > 0 ? true : false
        }
    }
    
    @IBOutlet weak var cashtagCollectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.cashtagCollectionView.delegate = self
        self.cashtagCollectionView.dataSource = self
        imageUrl.layer.cornerRadius = imageUrl.frame.size.height/2
        imageUrl.layer.masksToBounds = true
        imageUrl.layer.borderWidth = 0;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.cashtags.count
    }

    public func symbolTapped(_ symbol:String){
        self.parentVC?.setUsernameAndselectedCashtag(String(self.username.text!.dropFirst()), cashtag: symbol)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cashtag = self.cashtags[indexPath.row]
        let cell = self.cashtagCollectionView.dequeueReusableCell(withReuseIdentifier: "cashtagCell", for: indexPath) as! TwitterSymbolCollectionViewCell
        cell.symbol.text = cashtag.symbol ?? ""
        if cashtag.symbol == "RECENT" {
            cell.symbol.font = cell.symbol.font.withSize(CGFloat(14.0))
            cell.mainView.backgroundColor = Constants.lightblue
            cell.mainView.layer.borderColor = Constants.blue.cgColor
            cell.layer.borderColor = Constants.blue.cgColor
            cell.tweetCount.textColor = .white
            cell.sentiment.isHidden = true
            cell.face.isHidden = true
        } else {
            cell.symbol.font = cell.symbol.font.withSize(CGFloat(16.0))
            cell.symbol.textColor = .white
            cell.mainView.backgroundColor = UIColor(red: 30.0/255.0, green: 30.0/255.0, blue: 30.0/255.0, alpha: 1.0)
            cell.mainView.layer.borderColor = UIColor(red: 30.0/255.0, green: 30.0/255.0, blue: 30.0/255.0, alpha: 1.0).cgColor
            cell.layer.borderColor = UIColor(red: 30.0/255.0, green: 30.0/255.0, blue: 30.0/255.0, alpha: 1.0).cgColor
            cell.sentiment.isHidden = false
            cell.tweetCount.textColor = Constants.lightblue
            cell.face.isHidden = false
        }
        if cashtag.count == 1 {
            cell.tweetCount.text = String("1 tweet")
        } else {
            cell.tweetCount.text = String("\(cashtag.count ?? 0) tweets")
        }
        cell.sentiment.text = String(format: "%.2f", cashtag.overallSentiment ?? 0.0)
        cell.sentiment.textColor = self.getColorForSentiment(cashtag.overallSentiment ?? 0.0)
        cell.face.image = UIImage(named: self.getImageNameForSentiment(cashtag.overallSentiment ?? 0.0))
        cell.parentView = self
        return cell
    }
    
    private func getColorForSentiment(_ sent:Double) -> UIColor {
        if sent > 0.1 {
            return Constants.green
        } else if sent >= -0.1 {
            return Constants.yellow
        } else {
            return Constants.darkPink
        }
    }
    
    private func getImageNameForSentiment(_ sent:Double) -> String {
        if sent > 0.1 {
            return "happy.png"
        } else if sent >= -0.1 {
            return "neutral.png"
        } else {
            return "sad.png"
        }
    }
    
    public func setData(_ cashtags:[Cashtag]) {
        self.cashtags = cashtags
        self.cashtags.sort { a, b in
            a.count ?? 0 > b.count ?? 0
        }
        let allTweetsCount = self.cashtags.reduce(0) { $0 + ($1.count ?? 0) }
        var allCashtag = Cashtag()
        allCashtag.symbol = "RECENT"
        allCashtag.count = allTweetsCount
        allCashtag.overallSentiment = 0.0
        self.cashtags.insert(allCashtag, at: 0)
        DispatchQueue.main.async {
            self.cashtagCollectionView.reloadData()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
