//
//  Dataholder.swift
//  stonks
//
//  Created by Samuel Hobel on 9/30/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import Foundation

class Dataholder {
    
    public static var allTickers : [Company] = []
    public static var watchList : [Company] = [
        Company(ticker: "FB", fullName: "Facebook"),
        Company(ticker: "AMZN", fullName: "Amazon.com, Inc."),
        Company(ticker: "MSFT", fullName: "Microsoft Corporation"),
        Company(ticker: "MU", fullName: "Micron Technology"),
        Company(ticker: "V", fullName: "Visa Inc."),
        Company(ticker: "ATVI", fullName: "Activision Blizzard Inc"),
        Company(ticker: "TSLA", fullName: "Tesla Inc.")
    ]
    
    public static func updateWatchlistPriceInfo(quotes: [String: Double]){
        
        
    }
    
    public static func addToWatchList(company: Company) {
        if !watchList.contains(company){
            watchList.append(company)
        }
    }
    
    public static func removeFromWatchList(index: Int){
        watchList.remove(at: index)
    }
    
}
