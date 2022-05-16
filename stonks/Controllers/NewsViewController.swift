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

class NewsViewController: UIViewController, StatsVC {

    private var company:Company!
    @IBOutlet weak var newsCollectionView: UICollectionView!
    @IBOutlet weak var sentimentChart: SimplestLineChart!
    @IBOutlet weak var sentimentContainerHeight: NSLayoutConstraint!
    
    private var stockNews:[News] = []
    private var isLoaded:Bool = false
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
        
        self.company = Dataholder.selectedCompany!
        self.presentedViewController
        
    }
    
    func updateData() {
        if (!isLoaded) {
            if let p = self.parent?.parent?.parent as? StockDetailsVC {
                p.hideLoader(false)
            }
            NetworkManager.getMyRestApi().getSecondTabData(symbol: self.company.symbol, completionHandler: handleNewsAndSentiment)
        }
    }
    
    func handleNewsAndSentiment(news: [News], ss: [SocialSentimentFMP], ns: NewsSentiment){
        self.company.news = news
        self.stockNews = self.company.news ?? []
        
        var twitterSentiment:[Double] = []
        var stocktwitsSentiment:[Double] = []
        var previousStSent:Double = 0.0
        var previousTwSent:Double = 0.0
        for s in ss {
            if s.stocktwitsSentiment == nil || s.stocktwitsSentiment == 0.0 && previousStSent != 0.0 {
                stocktwitsSentiment.append(previousStSent)
            } else {
                stocktwitsSentiment.append(s.stocktwitsSentiment ?? 0.0)
                previousStSent = s.stocktwitsSentiment ?? 0.0
            }
            if s.twitterSentiment == nil || s.twitterSentiment == 0.0 && previousTwSent != 0.0 {
                twitterSentiment.append(previousTwSent)
            } else {
                twitterSentiment.append(s.twitterSentiment ?? 0.0)
                previousTwSent = s.twitterSentiment ?? 0.0
            }
        }

        DispatchQueue.main.async {
            self.newsCollectionView.reloadData()
            self.sentimentChart.setData([twitterSentiment, stocktwitsSentiment], colors: [Constants.blue, UIColor.white])
            self.sentimentChart.setLabelPosition(outside: true)
            if self.stockNews.count > 2 {
                self.newsCollectionView.scrollToItem(at: IndexPath(row: 1, section: 0), at: .centeredHorizontally, animated: true)
            }
            if let p = self.parent?.parent?.parent as? StockDetailsVC {
                p.adjustContentHeight(vc: self)
                p.hideLoader(true)
            }
        }
    }
    
    func getContentHeight() -> CGFloat {
        return self.sentimentContainerHeight.constant + 50 +  self.newsCollectionView.frame.size.height + 50
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
