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
    public var selectedCompany:Company?
    
    init(){
        watchlist = [
            Company(ticker: "FB", fullName: "Facebook", isCompany: true),
            Company(ticker: "AMZN", fullName: "Amazon.com, Inc.", isCompany: true),
            Company(ticker: "MSFT", fullName: "Microsoft Corporation", isCompany: true),
            Company(ticker: "MU", fullName: "Micron Technology", isCompany: true),
            Company(ticker: "V", fullName: "Visa Inc.", isCompany: true),
            Company(ticker: "ATVI", fullName: "Activision Blizzard Inc", isCompany: true),
            Company(ticker: "TSLA", fullName: "Tesla Inc.", isCompany: true),
            Company(ticker: "SPY", fullName: "SPDR S&P 500 ETF Trust", isCompany: false),
            Company(ticker: "QQQ", fullName: "PowerShares QQQ Trust", isCompany: false)
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
    
    public func getTickers(companiesOnly:Bool = false) -> [String] {
        var tickers:[String] = []
        for c in watchlist {
            if ((companiesOnly && c.isCompany) || !companiesOnly){
                tickers.append(c.ticker)
            }
        }
        return tickers
    }
    
}
