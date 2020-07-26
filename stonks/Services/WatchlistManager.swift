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
//            Company(symbol: "AAPL", fullName: "Apple Inc.", isCompany: true),
//            Company(symbol: "FB", fullName: "Facebook, Inc.", isCompany: true),
//            Company(symbol: "AMZN", fullName: "Amazon.com, Inc.", isCompany: true),
//            Company(symbol: "MSFT", fullName: "Microsoft Corporation", isCompany: true),
//            Company(symbol: "MU", fullName: "Micron Technology", isCompany: true),
//            Company(symbol: "V", fullName: "Visa Inc.", isCompany: true),
//            Company(symbol: "ATVI", fullName: "Activision Blizzard Inc", isCompany: true),
//            Company(symbol: "TSLA", fullName: "Tesla Inc.", isCompany: true),
//            Company(symbol: "NVDA", fullName: "NVIDIA Corporation", isCompany: true),
//            Company(symbol: "AMD", fullName: "Advanced Micro Devices, Inc.", isCompany: true),
//            Company(symbol: "SQ", fullName: "Square Inc", isCompany: true),
//            Company(symbol: "SPY", fullName: "SPDR S&P 500 ETF Trust", isCompany: false),
//            Company(symbol: "QQQ", fullName: "PowerShares QQQ Trust", isCompany: false),
//            Company(symbol: "SPCE", fullName: "Virgin Galactic", isCompany: true)
        ]
        sortWatchlist()
    }
    
    public func sortWatchlist(){
        watchlist.sort()
    }
    
    public func setWatchlist(_ companies:[Company]){
        self.watchlist = companies
    }

    public func getWatchlist() -> [Company] {
        return watchlist
    }
    
    public func getWatchlistSymbols() -> [String] {
        return watchlist.map{ $0.symbol }
    }

    public func addCompany(company: Company, completion: @escaping () -> Void){
        if !watchlist.contains(company) {
            watchlist.append(company)
            NetworkManager.getMyRestApi().addToWatchlist(symbol: company.symbol) { (JSON) in
                completion()
            }
        }
    }

    public func removeCompany(company: Company, completion: @escaping () -> Void){
        for i in 0..<self.watchlist.count {
            let c = watchlist[i]
            if c.symbol == company.symbol {
                watchlist.remove(at: i)
                NetworkManager.getMyRestApi().removeFromWatchlist(symbol: company.symbol) { (JSON) in
                    completion()
                }
                break
            }
        }
    }
    
    public func removeCompanyByIndex(index: Int, completion: @escaping () -> Void){
        let company = watchlist[index]
        watchlist.remove(at: index)
        NetworkManager.getMyRestApi().removeFromWatchlist(symbol: company.symbol) { (JSON) in
            completion()
        }
    }
    
    public func getTickers(companiesOnly:Bool = false) -> [String] {
        var tickers:[String] = []
        for c in watchlist {
            if ((companiesOnly && c.getIsCompany()) || !companiesOnly){
                tickers.append(c.symbol)
            }
        }
        return tickers
    }
    
}
