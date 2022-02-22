//
//  NewsViewController.swift
//  stonks
//
//  Created by Samuel Hobel on 9/12/19.
//  Copyright © 2019 Samuel Hobel. All rights reserved.
//

import UIKit
import SafariServices
import MSPeekCollectionViewDelegateImplementation

extension NewsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.stockNews.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "stockNewsCollectionCell", for: indexPath) as! StockNewsCollectionViewCell
        let news:News = self.stockNews[indexPath.row]
        cell.heading.text = news.headline
        cell.date.text = news.date
        let url = URL(string: news.image!)
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url!) {
                DispatchQueue.main.async {
                    cell.newImage.image = UIImage(data: data)
                }
            }
        }
        cell.source.text = news.source
        cell.symbols.text = news.related
        cell.url = news.url
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let stockNewsItem:News = self.stockNews[indexPath.row]
        let url = URL(string: stockNewsItem.url!)
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        var vc = SFSafariViewController(url: URL(string: "https://www.google.com")!)
        if (stockNewsItem.url?.starts(with: "http"))! {
            vc = SFSafariViewController(url: url!, configuration: config)
        }
        present(vc, animated: true)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
            behavior.scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
}

class NewsViewController: UIViewController, StatsVC, UITableViewDelegate, UITableViewDataSource {

    private var company:Company!
    private var isLoaded:Bool = false
    @IBOutlet weak var newsCollectionView: UICollectionView!
    @IBOutlet weak var stocktwitsTableView: UITableView!
    @IBOutlet weak var stocktwitsTableHeight: NSLayoutConstraint!
    
    private var stockNews:[News] = []
    private var stocktwitsPosts:[StocktwitsPost] = []
    private var stocktwitsTableHeights:[CGFloat] = []

    var behavior: MSCollectionViewPeekingBehavior!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.newsCollectionView.dataSource = self
        behavior = MSCollectionViewPeekingBehavior()
        behavior.cellPeekWidth = 50
        behavior.cellSpacing = 10
        behavior.minimumItemsToScroll = 1
        behavior.maximumItemsToScroll = 1
        behavior.numberOfItemsToShow = 1
        self.newsCollectionView.configureForPeekingBehavior(behavior: behavior)
        self.newsCollectionView.delegate = self

        self.stocktwitsTableView.delegate = self
        self.stocktwitsTableView.dataSource = self
        
        self.isLoaded = true
        self.company = Dataholder.selectedCompany!
        
        updateData()
    }
    
    func updateData() {
        self.company = Dataholder.selectedCompany!
        self.stockNews = self.company.news ?? []
//        NetworkManager.getMyRestApi().getStocktwitsPostsForSymbol(symbol: self.company.symbol, completionHandler: handleStocktwitsPosts)
        DispatchQueue.main.async {
            self.newsCollectionView.reloadData()
        }
    }
    
    func handleStocktwitsPosts(posts:[StocktwitsPost]){
        self.stocktwitsPosts = posts
        DispatchQueue.main.async {
            self.stocktwitsTableView.reloadData()
        }
    }
    
    func getContentHeight() -> CGFloat {
        if isLoaded {
            if self.stocktwitsPosts.isEmpty {
                return self.newsCollectionView.frame.height + 75
            } else {
                return self.stocktwitsTableHeight.constant + self.newsCollectionView.frame.height + 50
            }
        }
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.stocktwitsPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = stocktwitsTableView.dequeueReusableCell(withIdentifier: "detailStocktwitsTableViewCell") as! DetailStocktwitsTableViewCell
        let post = self.stocktwitsPosts[indexPath.row]
        cell.id = post.id
        cell.username.setTitle(post.username, for: .normal)
        cell.message.text = post.body
        
        if let body = post.body {
            let string = NSMutableAttributedString(string: body)
            string.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 16), range: NSRange(location: 0, length: string.length))
            let words:[String] = body.components(separatedBy:" ")
            for word in words {
                if word.count > 1 && word.hasPrefix("$"){
                    let index = word.index(word.startIndex, offsetBy: 1)
                    if String(word[index]).range(of: "[^a-zA-Z]", options: .regularExpression) == nil {
                        let range:NSRange = (string.string as NSString).range(of: word)
                        string.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: 18), range: range)
                        string.addAttribute(NSAttributedString.Key.link, value: NSURL(string: String("http://www.stocktwits.com/\(word)")) ?? "abcxyz", range: range)
                    }
                }
            }
            cell.message.attributedText = string
        }
        
        if let ts = post.timestamp {
            cell.timeButton.setTitle(Date(timeIntervalSince1970: TimeInterval(ts / 1000)).timeAgoSinceDate(), for: .normal)
        } else if let ca = post.createdAt {
            let ts = GeneralUtility.isoDateToTimestamp(isoString: ca)
            cell.timeButton.setTitle(Date(timeIntervalSince1970: TimeInterval(ts)).timeAgoSinceDate(), for: .normal)
        }
        if post.sentiment == "Bearish" {
            cell.bullbear.text = "BEARISH"
            cell.bullbear.textColor = Constants.darkPink
        } else if post.sentiment == "Bullish" {
            cell.bullbear.text = "BULLISH"
            cell.bullbear.textColor = Constants.green
        } else {
            cell.bullbear.text = "NEUTRAL"
            cell.bullbear.textColor = .lightGray
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.stocktwitsTableHeights.append(cell.frame.height)
        if self.stocktwitsTableHeights.count == self.stocktwitsPosts.count {
            let totalHeight = self.stocktwitsTableHeights.reduce(0, { x, y in
                x + y
            })
            DispatchQueue.main.async {
                self.stocktwitsTableHeights = []
                self.stocktwitsTableHeight.constant = totalHeight
                super.updateViewConstraints()
                if let p = self.parent?.parent?.parent as? StockDetailsVC {
                    p.adjustContentHeight(vc: self)
                }
            }
        }
    }

    @IBAction func stocktwitsTapped(_ sender: Any) {
        if let url = URL(string: String("http://www.stocktwits.com")) {
            UIApplication.shared.open(url)
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
