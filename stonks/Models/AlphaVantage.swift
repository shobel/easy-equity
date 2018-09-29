//
//  AlphaVantage.swift
//  stonks
//
//  Created by Samuel Hobel on 9/27/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import Foundation

final class AlphaVantage: StockDataAPI{
    
    static var sharedInstance: AlphaVantage = AlphaVantage()
    
    private var apiKey = "ME69ZQ2B0AVF5QTP" //alpha vantage api key
    private var requestFrequency = 30 //free version can handle 1 request every 30 seconds
    
    //query parameters:
    private enum timeIntervalChart {
        case TIME_SERIES_INTRADAY
        case TIME_SERIES_DAILY
    }
    
    private var timeIntervalCandle = (one: "1min", five: "5min", thirty: "30min")

}
