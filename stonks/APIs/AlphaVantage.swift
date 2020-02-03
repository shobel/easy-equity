//
//  AlphaVantage.swift
//  stonks
//
//  Created by Samuel Hobel on 9/17/19.
//  Copyright © 2019 Samuel Hobel. All rights reserved.
//

import Foundation
import SwiftyJSON
import ObjectMapper
class AlphaVantage: HTTPRequest, StockDataApiProtocol {
    
    private var url = "https://www.alphavantage.co/query?"
    private var apikey = "ME69ZQ2B0AVF5QTP"
    
    private var daily = "TIME_SERIES_DAILY_ADJUSTED" //Time Series (Daily)
    private var weekly = "TIME_SERIES_WEEKLY_ADJUSTED" //Weekly Time Series
    private var monthly = "TIME_SERIES_MONTHLY_ADJUSTED" //Monthly Time Series
    private var args = "function=TIME_SERIES_MONTHLY&symbol=MSFT&apikey=ME69ZQ2B0AVF5QTP"
    
    func getDailyChart(ticker: String, timeInterval: Constants.TimeIntervals, completionHandler: @escaping ([Candle]) -> Void) {
        let params = [
            "symbol": ticker,
            "function": daily,
            "outputsize": "compact",
            "apikey": apikey
        ]
        let queryURL = buildQuery(url: url, params: params)
        sendQuery(queryURL: queryURL, completionHandler: { (data, response, error) -> Void in
            if let data = data {
                let json = JSON(data)
                let jsonCandles = json["Time Series (Daily)"]
                var candleList:[Candle] = []
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                
                for (key, _):(String, JSON) in jsonCandles {
                    let dict = jsonCandles[key]
                    var open = Double(dict["1. open"].string!)!
                    var high = Double(dict["2. high"].string!)!
                    var low = Double(dict["3. low"].string!)!
                    var close = Double(dict["4. close"].string!)!
                    let adjustedClose = Double(dict["5. adjusted close"].string!)!
                    let volume = Double(dict["6. volume"].string!)!
                    if (adjustedClose != close){
                        let coeff = close / adjustedClose
                        open = open / coeff
                        high = high / coeff
                        close = close / coeff
                        low = low / coeff
                    }
                    
                    let datetime = NumberFormatter.formatDate(key)
                    let date = dateFormatter.date(from: key)!
                    candleList.append(Candle(date: date, datetime: datetime, volume: volume, high: high, low: low, open: open, close: close))
                }
                completionHandler(candleList)
            }
        })

    }
    
    func getWeeklyChart(ticker: String, timeInterval: Constants.TimeIntervals, completionHandler: @escaping ([Candle]) -> Void) {
        let params = [
            "symbol": ticker,
            "function": weekly,
            "outputsize": "full",
            "apikey": apikey
        ]
        let queryURL = buildQuery(url: url, params: params)
        sendQuery(queryURL: queryURL, completionHandler: { (data, response, error) -> Void in
            if let data = data {
                let json = JSON(data)
                let jsonCandles = json["Weekly Adjusted Time Series"]
                var candleList:[Candle] = []
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                
                for (key,_):(String, JSON) in jsonCandles {
                    let dict = jsonCandles[key]
                    var open = Double(dict["1. open"].string!)!
                    var high = Double(dict["2. high"].string!)!
                    var low = Double(dict["3. low"].string!)!
                    var close = Double(dict["4. close"].string!)!
                    let adjustedClose = Double(dict["5. adjusted close"].string!)!
                    let volume = Double(dict["6. volume"].string!)!
                    if (adjustedClose != close){
                        let coeff = close / adjustedClose
                        open = open / coeff
                        high = high / coeff
                        close = close / coeff
                        low = low / coeff
                    }
                    let datetime = NumberFormatter.formatDate(key)
                    let date = dateFormatter.date(from: key)!
                    candleList.append(Candle(date: date, datetime: datetime, volume: volume, high: high, low: low, open: open, close: close))
                }
                completionHandler(candleList)
            }
        })
    }
    
    func getMonthlyChart(ticker: String, timeInterval: Constants.TimeIntervals, completionHandler: @escaping ([Candle]) -> Void) {
        let params = [
            "symbol": ticker,
            "function": monthly,
            "outputsize": "full",
            "apikey": apikey
        ]
        let queryURL = buildQuery(url: url, params: params)
        sendQuery(queryURL: queryURL, completionHandler: { (data, response, error) -> Void in
            if let data = data {
                let json = JSON(data)
                let jsonCandles = json["Monthly Adjusted Time Series"]
                var candleList:[Candle] = []
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                
                for (key,_):(String, JSON) in jsonCandles {
                    let dict = jsonCandles[key]
                    var open = Double(dict["1. open"].string!)!
                    var high = Double(dict["2. high"].string!)!
                    var low = Double(dict["3. low"].string!)!
                    var close = Double(dict["4. close"].string!)!
                    let adjustedClose = Double(dict["5. adjusted close"].string!)!
                    let volume = Double(dict["6. volume"].string!)!
                    if (adjustedClose != close){
                        let coeff = close / adjustedClose
                        open = open / coeff
                        high = high / coeff
                        close = close / coeff
                        low = low / coeff
                    }
                    let datetime = NumberFormatter.formatDate(key)
                    let date = dateFormatter.date(from: key)!
                    candleList.append(Candle(date: date, datetime: datetime, volume: volume, high: high, low: low, open: open, close: close))
                }
                completionHandler(candleList)
            }
        })
    }
    
    func getChartForDate(ticker: String, date: String, completionHandler: @escaping ([Candle]) -> Void) {
        
    }
    
    func getQuote(ticker: String) {
        
    }
    
    func getQuotes(tickers: [String], completionHandler: @escaping ([Quote]) -> Void) {
        
    }
    
    func getCompanyGeneralInfo(ticker: String, completionHandler: @escaping (GeneralInfo, String) -> Void) {
        
    }
    
    func listCompanies() {
        
    }
    
    func getKeyStats(ticker: String, completionHandler: @escaping (KeyStats) -> Void) {
        
    }
    
    func getNews(ticker: String, completionHandler: @escaping ([News]) -> Void) {
        
    }
    
    func getAllData(ticker: String, completionHandler: @escaping (GeneralInfo, String, KeyStats, [News], PriceTarget, Earnings, Recommendations, AdvancedStats, Financials, Estimates) -> Void) {
        
    }
    
    func getPriceTarget(ticker: String, completionHandler: @escaping (PriceTarget) -> Void) {
        
    }
    
    func getEarnings(ticker: String, completionHandler: @escaping ([Earnings]) -> Void) {
        
    }
    
    func getRecommendations(ticker: String, completionHandler: @escaping ([Recommendations]) -> Void) {
        
    }
    
    func getAdvancedStats(ticker: String, completionHandler: @escaping (AdvancedStats) -> Void) {
        
    }
    
    func getFinancials(ticker: String, completionHandler: @escaping (Financials) -> Void) {
        
    }
    
    func getEstimates(ticker: String, completionHandler: @escaping (Estimates) -> Void) {
        
    }
    
}
