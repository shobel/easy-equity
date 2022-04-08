//
//  Dataholder.swift
//  stonks
//
//  Created by Samuel Hobel on 9/30/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import Foundation
import UIKit

class Dataholder {
    
    public static var allTickers: [Company] = []
    public static var selectedCompany:Company?
    public static var watchlistManager: WatchlistManager = WatchlistManager()
    public static var userScoreSettings: ScoreSettings = ScoreSettings()
    public static var isUSMarketOpen:Bool = false
    private static var currentCredits:Int = 0
    public static var currentScoringSystem:String = ""
    public static var lastScoreConfigChange:Double = 0
    
    public static var creditBalanceSubscribers:[ShadowButtonDelegate] = []
    
    public static func getCreditBalance() -> Int {
        return Dataholder.currentCredits
    }
    
    public static func subscribeForCreditBalanceUpdates(_ sub:ShadowButtonDelegate) {
        if !Dataholder.creditBalanceSubscribers.contains(where: { sbd in
            if let sbd = sbd as? UIViewController, let sub = sub as? UIViewController {
                if sbd.title == sub.title {
                    return true
                }
            }
            return false
        }) {
            creditBalanceSubscribers.append(sub)
        }
    }
    
    public static func updateCreditBalance(_ newBalance:Int) {
        self.currentCredits = newBalance
        for sbd in self.creditBalanceSubscribers {
            sbd.creditBalanceUpdated()
        }
    }
    
}
