//
//  WatchlistUpdater.swift
//  stonks
//
//  Created by Samuel Hobel on 10/7/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import Foundation
import UIKit

protocol RepeatingUpdate {
    func startTask()
    func stopTask()
    func update()
}

protocol Updateable {
    func updateFromScheduledTask(_ data:Any?)
}

class StockDataTask: RepeatingUpdate {
    
    var timer:Timer?
    var caller: Updateable!
    var timeInterval: Double = 30.0
    public var hibernating:Bool = false
    
    public init(caller: Updateable, timeInterval: Double){
        self.caller = caller
        self.timeInterval = timeInterval
    }
    
    public func startTask() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: self.timeInterval, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
            timer?.fire()
        }
    }
    
    public func stopTask() {
        if timer != nil{
            timer!.invalidate()
            timer = nil
        }
    }
    
    @objc public func update() {
        
    }
    
}

class WatchlistUpdater: StockDataTask {
    
    var watchlistManager: WatchlistManager!
    var watchlist: [Company]!
    
    public override init(caller: Updateable, timeInterval: Double){
        super.init(caller: caller, timeInterval: timeInterval)
        self.watchlistManager = Dataholder.watchlistManager
        self.watchlist = watchlistManager.getWatchlist()
    }
    
    @objc override func update(){
        if (!hibernating){
            DispatchQueue.global(qos: .background).async {
                let tickers = self.watchlistManager.getTickers()
                NetworkManager.getMyRestApi().getQuotesAndSimplifiedCharts(symbols: tickers, completionHandler: { (quotes: [Quote])->Void in
                    for c in self.watchlist {
                        for q in quotes {
                            if (c.symbol == q.symbol) {
                                c.quote = q
                            }
                        }
                    }
                    self.watchlistManager.sortWatchlist()
                    self.caller.updateFromScheduledTask(nil)
                })
            }
        }
    }
}
