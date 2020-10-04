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
            let newTimer = Timer.scheduledTimer(timeInterval: self.timeInterval, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
            self.timer = newTimer
            print(String("new timer created with interval \(self.timer!.timeInterval)s"))
            newTimer.fire()
        }
    }
    
    public func stopTask() {
        if timer != nil{
            print(String("existing timer with interval \(self.timer!.timeInterval)s invalidated"))
            timer!.invalidate()
            timer = nil
        }
    }
    
    public func changeTimeInterval(newTimeInterval:Double) {
        DispatchQueue.main.async {
            if self.timeInterval != newTimeInterval {
                self.stopTask()
                self.timeInterval = newTimeInterval
                self.startTask()
            }
        }
    }
    
    @objc public func update() {}
    
}

class WatchlistUpdater: StockDataTask {
    
    var watchlistManager: WatchlistManager!
    var watchlist: [Company]!
    var lastFire: Int?
    var numUpdates = 0
    
    public override init(caller: Updateable, timeInterval: Double){
        super.init(caller: caller, timeInterval: timeInterval)
        self.watchlistManager = Dataholder.watchlistManager
        self.watchlist = watchlistManager.getWatchlist()
    }
    
    @objc override func update(){
        numUpdates += 1
        let now:Int = Int(Date().timeIntervalSince1970)
        if lastFire != nil {
            let diff = (now - lastFire!)
            print(String("WU (hibernating: \(hibernating)): \(diff)"))
        }
        lastFire = now

        if (!hibernating){
            DispatchQueue.global(qos: .background).async {
                let tickers = self.watchlistManager.getTickers()
                //print("watchlist updater fired!")
                NetworkManager.getMyRestApi().getQuotesAndSimplifiedCharts(symbols: tickers, completionHandler: { (quotes: [Quote])->Void in
                    for c in self.watchlistManager.getWatchlist() {
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
        } else {
            self.caller.updateFromScheduledTask(nil)
        }
    }
    
}
