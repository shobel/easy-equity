//
//  Quote.swift
//  stonks
//
//  Created by Samuel Hobel on 10/8/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import Foundation

struct Quote {
    
    var symbol:String // "AAPL"
    var latestPrice:Double //224.29
    var previousClose:Double //227.99
    var change:Double //-3.7
    var changePercent:Double //-0.01623 *NOT A PERCENT - NEED TO x100
    var isLive:Bool //"latestSource":"Close",
    var extendedPrice:Double //"extendedPrice":224.54
    var extendedChangePercent:Double //"extendedChangePercent":0.00111
    var sector:String //"sector":"Technology"
    var marketCap:Double //"marketCap":1083304102540
    var ytdChange:Double //"ytdChange":0.3007662925165673
    
    //"companyName":"Apple Inc.",
    //"primaryExchange":"Nasdaq Global Select",
    //"calculationPrice":"close",
    //"open":227.96,
    //"openTime":1538746200385,
    //"close":224.29,
    //"closeTime":1538769600416,
    //"high":228.41,
    //"low":220.58,
    //"latestTime":"October 5, 2018",
    //"latestUpdate":1538769600416,
    //"latestVolume":33382188,
    //"extendedChange":0.25,
    //"extendedPriceTime":1538773180262,
    //"avgTotalVolume":33426843,
    //"peRatio":20.33,
    //"week52High":233.47,
    //"week52Low":150.24,
    //"ytdChange":0.3007662925165673
}
