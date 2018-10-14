//
//  Watchlist.swift
//  stonks
//
//  Created by Samuel Hobel on 10/13/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import Foundation

class WatchlistManager {
    
    private var watchlist:[Company]
    
    init(){
        watchlist = [
            Company(ticker: "FB", fullName: "Facebook"),
            Company(ticker: "AMZN", fullName: "Amazon.com, Inc."),
            Company(ticker: "MSFT", fullName: "Microsoft Corporation"),
            Company(ticker: "MU", fullName: "Micron Technology"),
            Company(ticker: "V", fullName: "Visa Inc."),
            Company(ticker: "ATVI", fullName: "Activision Blizzard Inc"),
            Company(ticker: "TSLA", fullName: "Tesla Inc.")
        ]
    }
    
    public func getWatchlist() -> [Company] {
        return watchlist
    }
    
    public func addCompany(company: Company){
        if !watchlist.contains(company) {
            watchlist.append(company)
        }
    }
    
    public func removeCompany(index: Int){
        watchlist.remove(at: index)
    }
    
    public func getTickers() -> [String] {
        var tickers:[String] = []
        for c in watchlist {
            tickers.append(c.ticker)
        }
        return tickers
    }
    
}
