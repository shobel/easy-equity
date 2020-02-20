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
            Company(symbol: "AAPL", fullName: "Apple Inc.", isCompany: true),
            Company(symbol: "FB", fullName: "Facebook, Inc.", isCompany: true),
            Company(symbol: "AMZN", fullName: "Amazon.com, Inc.", isCompany: true),
            Company(symbol: "MSFT", fullName: "Microsoft Corporation", isCompany: true),
            Company(symbol: "MU", fullName: "Micron Technology", isCompany: true),
            Company(symbol: "V", fullName: "Visa Inc.", isCompany: true),
            Company(symbol: "ATVI", fullName: "Activision Blizzard Inc", isCompany: true),
            Company(symbol: "TSLA", fullName: "Tesla Inc.", isCompany: true),
            Company(symbol: "NVDA", fullName: "NVIDIA Corporation", isCompany: true),
            Company(symbol: "AMD", fullName: "Advanced Micro Devices, Inc.", isCompany: true),
            Company(symbol: "SQ", fullName: "Square Inc", isCompany: true),
            Company(symbol: "SPY", fullName: "SPDR S&P 500 ETF Trust", isCompany: false),
            Company(symbol: "QQQ", fullName: "PowerShares QQQ Trust", isCompany: false),
            Company(symbol: "SPCE", fullName: "Virgin Galactic", isCompany: true)
        ]
        sortWatchlist()
    }
    
    public func sortWatchlist(){
        watchlist.sort()
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
                tickers.append(c.symbol)
            }
        }
        return tickers
    }
    
}
