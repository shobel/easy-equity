//
//  StockUpdater.swift
//  stonks
//
//  Created by Samuel Hobel on 1/21/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import Foundation

class StockUpdater: StockDataTask {
    
    private var tickers:[String] = []
    
    public init(caller: Updateable, ticker: String, timeInterval: Double) {
        super.init(caller: caller, timeInterval: timeInterval)
        self.tickers.append(ticker)
    }
    
    @objc override func update(){
        DispatchQueue.global(qos: .background).async {
            StockAPIManager.shared.stockDataApiInstance.getQuotes(tickers: self.tickers, completionHandler: { (quotes: [Quote])->Void in
                self.caller.updateFromScheduledTask(quotes)
            })
        }
    }
    
}
