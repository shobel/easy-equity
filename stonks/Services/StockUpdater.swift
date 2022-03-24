//
//  StockUpdater.swift
//  stonks
//
//  Created by Samuel Hobel on 1/21/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import Foundation

class QuoteAndIntradayChart {
    var quote:Quote!
    var intradayChart:[Candle] = []
    init(quote:Quote, intradayChart:[Candle]){
        self.quote = quote
        self.intradayChart = intradayChart
    }
    
}

//used by stockdetailsvc to constantly update latest quote and intraday chart
class StockUpdater: StockDataTask {
    
    private var company:Company!
    var lastFire: Int = 0

    public init(caller: Updateable, company: Company, timeInterval: Double) {
        super.init(caller: caller, timeInterval: timeInterval)
        self.company = company
    }
    
    @objc override func update(){
        let now:Int = Int(Date().timeIntervalSince1970)
        let diff = (now - lastFire)
        print(String("SU (hibernating: \(hibernating)): \(diff)"))

        if (!hibernating){
            DispatchQueue.global(qos: .background).async {
                NetworkManager.getMyRestApi().getQuoteAndIntradayChart(symbol: self.company.symbol) { (quote, candles) in
                    let quoteAndIntradayChart = QuoteAndIntradayChart(quote: quote, intradayChart: candles)
                    self.caller.updateFromScheduledTask(quoteAndIntradayChart)
                }
            }
        } else {
            self.caller.updateFromScheduledTask(nil)
        }
    }
    
}
