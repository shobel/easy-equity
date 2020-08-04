//
//  StockUpdater.swift
//  stonks
//
//  Created by Samuel Hobel on 1/21/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import Foundation

struct QuoteAndIntradayChart {
    var quote:Quote
    var intradayChart:[Candle]
    
}

//used by stockdetailsvc to constantly update latest quote and intraday chart
class StockUpdater: StockDataTask {
    
    private var company:Company!
    
    public init(caller: Updateable, company: Company, timeInterval: Double) {
        super.init(caller: caller, timeInterval: timeInterval)
        self.company = company
    }
    
    @objc override func update(){
        DispatchQueue.global(qos: .background).async {
            NetworkManager.getMyRestApi().getQuoteAndIntradayChart(symbol: self.company.symbol, minutes: self.company.minuteData.count) { (quote, candles) in
                let quoteAndIntradayChart = QuoteAndIntradayChart(quote: quote, intradayChart: candles)
                self.caller.updateFromScheduledTask(quoteAndIntradayChart)
            }
        }
    }
    
}
