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

    var appId = "ca-app-pub-8062944595412058~4380873182"
    var appOpenAd: GADAppOpenAd?
    var realAdUnitIdRewarded = "ca-app-pub-8062944595412058/5058989059"
    var testAdUnitIdRewarded = "ca-app-pub-3940256099942544/1712485313"
    var testAdUnitIdInterstitial = "ca-app-pub-3940256099942544/4411468910"
    @IBOutlet var mainView: UIView!
    private var rewardedAd: GADRewardedAd?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainView.addPurpleGradientBackground()
        self.loadRewardedAd()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
        
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func donateButton(_ sender: Any) {
        if let url = URL(string: "https://sites.google.com/view/stoccoon/home") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func viewAnAd(_ sender: Any) {
        self.show()
    }
    
    func loadRewardedAd() {
        let request = GADRequest()
        GADRewardedAd.load(withAdUnitID: self.realAdUnitIdRewarded,
                       request: request, completionHandler: { [self] ad, error in
        if let error = error {
            print("Failed to load rewarded ad with error: \(error.localizedDescription)")
            return
        }
        rewardedAd = ad
        print("Rewarded ad loaded.")
        rewardedAd?.fullScreenContentDelegate = self
      }
      )
    }
    
    func show() {
      if let ad = rewardedAd {
        ad.present(fromRootViewController: self) {
          let reward = ad.adReward
          print("Reward received with currency \(reward.amount), amount \(reward.amount.doubleValue)")
          // TODO: Reward the user.
        }
      } else {
        print("Ad wasn't ready")
      }
    }

//    func requestAppOpenAd() {
//        let request = GADRequest()
//        GADAppOpenAd.load(withAdUnitID: self.testAdUnitIdInterstitial,
//                          request: request,
//                          orientation: UIInterfaceOrientation.portrait,
//                          completionHandler: { (appOpenAdIn, _) in
//                            self.appOpenAd = appOpenAdIn
//                            self.appOpenAd?.fullScreenContentDelegate = self
//                            self.loadTime = Date()
//                            print("Ad is ready")
//                            self.tryToPresentAd()
//                          })
//    }

//    func tryToPresentAd() {
//        if let gOpenAd = self.appOpenAd, wasLoadTimeLessThanNHoursAgo(thresholdN: 4) {
//            gOpenAd.present(fromRootViewController: self)
//        } else {
//            self.requestAppOpenAd()
//        }
//    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("dismissed")
        self.loadRewardedAd()
    }

    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("will present")
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
