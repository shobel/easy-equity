//
//  WatchlistUpdater.swift
//  stonks
//
//  Created by Samuel Hobel on 10/7/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import Foundation
import UIKit

class WatchlistUpdater {
    
    var updateWatchlistTimer:Timer?
    var caller: WatchlistVC
    
    var watchlistManager: WatchlistManager!
    var watchlist: [Company]!
    
    public init(caller: WatchlistVC){
        self.caller = caller
        self.watchlistManager = Dataholder.watchlistManager
        self.watchlist = watchlistManager.getWatchlist()
    }
    
    public func startTask(){
        if updateWatchlistTimer == nil {
            updateWatchlistTimer = Timer.scheduledTimer(timeInterval: 15.0, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
            updateWatchlistTimer?.fire()
        }
    }
    
    public func stopTask(){
        if updateWatchlistTimer != nil{
            updateWatchlistTimer!.invalidate()
            updateWatchlistTimer = nil
        }
    }
    
    @objc func update(){
        DispatchQueue.global(qos: .background).async {
            let tickers = self.watchlistManager.getTickers()
            StockAPIManager.shared.stockDataApiInstance.getQuotes(tickers: tickers, completionHandler: { (quotes: [Quote])->Void in
                for c in self.watchlist {
                    for q in quotes {
                        if (c.ticker == q.symbol) {
                            c.quote = q
                        }
                    }
                }
                self.caller.update()
            })
        }
    }
    
}
