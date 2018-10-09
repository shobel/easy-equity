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
    var caller: WatchlistTVC
    
    public init(caller: WatchlistTVC){
        self.caller = caller
    }
    
    public func startTask(){
        if updateWatchlistTimer == nil {
            updateWatchlistTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
            updateWatchlistTimer?.fire()
        }
    }
    
    public func stopTask(){
        if updateWatchlistTimer != nil{
            updateWatchlistTimer!.invalidate()
            updateWatchlistTimer = nil
        }
    }
    
    private func getTickerStringArray() -> [String]{
        var tickers:[String] = []
        for company in Dataholder.watchList {
            tickers.append(company.ticker)
        }
        return tickers
    }
    
    @objc func update(){
        DispatchQueue.global(qos: .background).async {
            let tickers = self.getTickerStringArray()
            StockAPIManager.shared.getStockDataAPI().getQuotes(tickers: tickers, completionHandler: { (quotes: [Quote])->Void in
                for c in Dataholder.watchList {
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
