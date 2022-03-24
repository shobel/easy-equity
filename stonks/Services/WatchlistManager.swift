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
    private var limit:Int = 30
    
    init(){
        watchlist = []
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

    public func addCompany(company: Company, completion: @escaping (Bool) -> Void){
        if !watchlist.contains(company) {
            if (watchlist.count >= limit){
                completion(false)
            } else {
                watchlist.append(company)
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
    
    public func getTickers() -> [String] {
        return watchlist.map { (c) -> String in c.symbol }
    }
    
}
