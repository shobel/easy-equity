//
//  LaunchVC.swift
//  stonks
//
//  Created by Samuel Hobel on 10/26/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import UIKit
import FirebaseUI

class LaunchVC: UIViewController, FUIAuthDelegate {

    private var finvizAPI:FinvizAPI!
    private var watchlistManager:WatchlistManager!
    private var numTotal:Int!
    private var numUpdated = 0
    
    private var authUI:FUIAuth?
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    /*  This method is initiating the async call to get all stocks
     It also gets all the ratings from Finviz and won't return until it has all the ratings
     
     TODO: This should only happen the first time you launch the app because it is just to avoid seeing empty ratings. When saving and retrieving local data is implemented, we can skip this loading step show the old ratings until they are updated in the next view
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        StockAPIManager.shared.stockDataApiInstance.listCompanies()
        
        watchlistManager = Dataholder.watchlistManager
        numTotal = 0
//        for c in watchlistManager.getWatchlist() {
//            if c.isCompany {
//                numTotal += 1
//            }
//        }
        
        //added line below to perform segue
        self.addProgress()
        finvizAPI = FinvizAPI()
        //finvizAPI.getData(forTickers: watchlistManager.getTickers(companiesOnly: true), completionHandler: handleFinvizResponse)
    }
    
    func addProgress(){
        DispatchQueue.main.async {
            self.numUpdated += 1
            let progress = Float(Float(self.numUpdated)/Float(self.numTotal))
            self.progressBar.setProgress(progress, animated: true)
            
            if self.numUpdated >= self.numTotal {
                self.performSegue(withIdentifier: "toAuth", sender: self)
                //self.launchAuth()
            }
        }
    }
    
    func handleFinvizResponse(data: [String:[String:Any?]]){
        for c in watchlistManager.getWatchlist(){
            if let ticker = data.keys.first {
                if ticker == c.symbol {
                    c.analystsRating = data[ticker]!["ratings"] as? AnalystsRating
                    
                    let earningsDateString = data[ticker]!["Earnings"] as? String
                    let erArray = earningsDateString?.components(separatedBy: .whitespaces)
                    _ = erArray![2]
                    
                    let today = Date()
                    let calendar = Calendar.current
                    let year = calendar.component(.year, from: today)
                    
                    let earningsDate = erArray![0] + " " + erArray![1] + " " + String(year)
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MMM dd yyyy"
                    dateFormatter.timeZone = TimeZone(abbreviation: "EST")
                    guard let date = dateFormatter.date(from: earningsDate) else {
                        fatalError()
                    }
                    c.earningsDate = date
                    break
                }
            }
        }
        self.addProgress()
    }
    
    func launchAuth(){
        self.authUI = FUIAuth.defaultAuthUI()
        guard self.authUI != nil else {
            return
        }
                
        self.authUI!.delegate = self
                
//        let actionCodeSettings = ActionCodeSettings()
//        actionCodeSettings.url = URL(string: "https://example.appspot.com")
//        actionCodeSettings.handleCodeInApp = true
//        actionCodeSettings.setAndroidPackageName("com.firebase.example", installIfNotAvailable: false, minimumVersion: "12")
//        let emailProvider = FUIEmailAuth(authAuthUI: FUIAuth.defaultAuthUI()!,
//                            signInMethod: EmailLinkAuthSignInMethod,
//                            forceSameDevice: false,
//                            allowNewEmailAccounts: true,
//                            actionCodeSetting: actionCodeSettings)
//
//        let providers: [FUIAuthProvider] = [emailProvider]
//        self.authUI!.providers = providers
                
        let authViewController = self.authUI!.authViewController()
        self.present(authViewController, animated: true, completion: nil)
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        guard error == nil else {
            return
        }
        let userId = authDataResult?.user.uid
        self.performSegue(withIdentifier: "toHome", sender: self)
    }
    
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
 */
}
