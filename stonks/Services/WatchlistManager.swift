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
    private var portfolio:[Company]
    private var limit:Int = 30
    
    public var watchlistVC:WatchlistVC?
    
    init(){
        watchlist = []
        portfolio = []
        sortWatchlist()
    }
    
    public func getPortfolio() -> [Company]{
        return portfolio.sorted { a, b in
            a.symbol < b.symbol
        }
    }
    
    public func setPortfolio(_ companies: [Company]){
        self.portfolio = companies
    }
    
    public func sortWatchlist(){
        watchlist.sort()
    }
    
    public func setWatchlist(_ companies:[Company]){
        self.watchlist = companies
    }

    public func getWatchlist() -> [Company] {
        return watchlist.sorted { a, b in
            a.symbol < b.symbol
        }
    }
    
    public func getWatchlistSymbols() -> [String] {
        return watchlist.map{ $0.symbol }
    }
    public func getPortfolioSymbols() -> [String] {
        return portfolio.map{ $0.symbol }
    }
    public func getAllTickers() -> [String] {
        var tickers:[String] = []
        for w in watchlist {
            tickers.append(w.symbol)
        }
        for p in portfolio {
            tickers.append(p.symbol)
        }
        return tickers
    }
    
    public func addCompany(company: Company, completion: @escaping (Bool) -> Void){
        if !watchlist.contains(company) {
            if (watchlist.count >= limit){
                completion(false)
            } else {
                watchlist.append(company)
                self.watchlistVC?.watchlistUpdated()
                NetworkManager.getMyRestApi().addToWatchlist(symbol: company.symbol) { (JSON) in
                    completion(true)
                }
            }
        }
    }

    public func removeCompany(company: Company, completion: @escaping () -> Void){
        for i in 0..<self.watchlist.count {
            let c = watchlist[i]
            if c.symbol == company.symbol {
                watchlist.remove(at: i)
                self.watchlistVC?.watchlistUpdated()
                NetworkManager.getMyRestApi().removeFromWatchlist(symbol: company.symbol) { (JSON) in
                    completion()
                }
                break
            }
        }
    }
    
    public func removeCompanyBySymbol(symbol: String, completion: @escaping () -> Void){
        for i in 0..<self.watchlist.count {
            let c = watchlist[i]
            if c.symbol == symbol {
                watchlist.remove(at: i)
                self.watchlistVC?.watchlistUpdated()
                NetworkManager.getMyRestApi().removeFromWatchlist(symbol: symbol) { (JSON) in
                    completion()
                }
                break
            }
        }
    }
    
    public func removeCompanyByIndex(index: Int, completion: @escaping () -> Void){
        let company = watchlist[index]
        watchlist.remove(at: index)
        self.watchlistVC?.watchlistUpdated()
        NetworkManager.getMyRestApi().removeFromWatchlist(symbol: company.symbol) { (JSON) in
            completion()
        }
    }
    
}
