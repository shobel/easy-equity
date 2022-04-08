//
//  WatchAdsViewController.swift
//  stonks
//
//  Created by Samuel Hobel on 2/20/22.
//  Copyright © 2022 Samuel Hobel. All rights reserved.
//

import UIKit
import GoogleMobileAds
import SafariServices

class WatchAdsViewController: UIViewController, GADFullScreenContentDelegate {

    var appOpenAd: GADAppOpenAd?
    var loadTime = Date()
    var testAdUnitIdRewarded = "ca-app-pub-3940256099942544/1712485313"
    var testAdUnitIdInterstitial = "ca-app-pub-3940256099942544/4411468910"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
        
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func donateButton(_ sender: Any) {
        if let url = URL(string: "https://cash.app/$SamHobel") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func donateVenmo(_ sender: Any) {
        if let url = URL(string: "https://venmo.com/code?user_id=1834400002080768409") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func viewAnAd(_ sender: Any) {
        self.tryToPresentAd()
    }
    
    func requestAppOpenAd() {
        let request = GADRequest()
        GADAppOpenAd.load(withAdUnitID: self.testAdUnitIdInterstitial,
                          request: request,
                          orientation: UIInterfaceOrientation.portrait,
                          completionHandler: { (appOpenAdIn, _) in
                            self.appOpenAd = appOpenAdIn
                            self.appOpenAd?.fullScreenContentDelegate = self
                            self.loadTime = Date()
                            print("Ad is ready")
                            self.tryToPresentAd()
                          })
    }

    func tryToPresentAd() {
        if let gOpenAd = self.appOpenAd, wasLoadTimeLessThanNHoursAgo(thresholdN: 4) {
            gOpenAd.present(fromRootViewController: self)
        } else {
            self.requestAppOpenAd()
        }
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("dismissed")
//        self.dismiss(animated: true)
    }

    func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did present")
    }

    func wasLoadTimeLessThanNHoursAgo(thresholdN: Int) -> Bool {
        let now = Date()
        let timeIntervalBetweenNowAndLoadTime = now.timeIntervalSince(self.loadTime)
        let secondsPerHour = 3600.0
        let intervalInHours = timeIntervalBetweenNowAndLoadTime / secondsPerHour
        return intervalInHours < Double(thresholdN)
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
