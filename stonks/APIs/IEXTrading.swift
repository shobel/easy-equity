//
//  IEXTrading.swift
//  stonks
//
//  Created by Samuel Hobel on 9/28/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import Foundation
import SwiftyJSON

class IEXTrading: HTTPRequest, StockDataApiProtocol {

    private var stockURL = "https://api.iextrading.com/1.0/stock/"
    private var batchURL = "https://api.iextrading.com/1.0/stock/market/batch?"
    private var listURL = "https://api.iextrading.com/1.0/ref-data/symbols"

    private var queries = (
        chart: "chart",
        company: "company",
        earnings: "earnings",
        logo: "logo",
        news: "news",
        quote: "quote"
    )
    
    private var stockTypes = (
        common: "cs",
        exchangeTraded: "et"
    )
    
    private var timeFrames = [
        Constants.TimeIntervals.day: "1d",
        Constants.TimeIntervals.one_month: "1m",
        Constants.TimeIntervals.three_month: "3m",
        Constants.TimeIntervals.six_month: "6m",
        Constants.TimeIntervals.one_year: "1y",
        Constants.TimeIntervals.five_year: "5y"
    ]
    
    //iexendpoints: logo and company
    func getCompanyData(ticker: String, completionHandler: @escaping ([String:String])->Void) {
        var returnDict:[String:String] = [:]
        let params = [
            "symbols": ticker,
            "types": "logo,company"
        ]
        let queryURL = buildQuery(url: batchURL, params: params)
        sendQuery(queryURL: queryURL, completionHandler: { (data, response, error) -> Void in
            if let data = data {
                let json = JSON(data)
                returnDict["description"] = json[ticker]["company"]["description"].string!
                returnDict["ceo"] = json[ticker]["company"]["CEO"].string!
                returnDict["logo"] = json[ticker]["logo"]["url"].string!
                //print(json)
                completionHandler(returnDict)
            }
        })

    }
    
    func getChart(ticker: String, timeInterval: Constants.TimeIntervals, completionHandler: ([Candle])->Void) {
        let params:[String] = [stockURL, ticker, queries.chart, timeFrames[timeInterval]!]
        let queryURL = params.joined(separator: "/")
        
        sendQuery(queryURL: queryURL, completionHandler: { (data, response, error) -> Void in
            if let data = data {
                let json = JSON(data)
                var candle:Candle
                for i in 0..<json.count{
                    //candle = Candle(date: json[i]["date"].string!, volume: json[i]["volume"].double!, high: json[i]["high"].double!, low: json[i]["low"].double!, open: json[i]["open"].double!, close: json[i]["close"].double!)
                }
                //print(json)
            }
        })
    }
    
    func getQuotes(tickers: [String], completionHandler: @escaping ([Quote])->Void){
        let params = [
            "symbols": tickers.joined(separator: ","),
            "types": "quote"
        ]
        let queryURL = buildQuery(url: batchURL, params: params)
        sendQuery(queryURL: queryURL, completionHandler: { (data, response, error) -> Void in
            if let data = data {
                let json = JSON(data)
                var quotes:[Quote] = []
                for (ticker,_):(String, JSON) in json {
                    let iexLatestSource = json[ticker]["quote"]["latestSource"].string
                    var isLive = false
                    if iexLatestSource != nil {
                        if iexLatestSource == "IEX real time price" {
                            isLive = true
                        }
                    }
                    let quote = Quote(
                        symbol: json[ticker]["quote"]["symbol"].string!,
                        latestPrice:json[ticker]["quote"]["latestPrice"].double!,
                        previousClose: json[ticker]["quote"]["previousClose"].double!,
                        change: json[ticker]["quote"]["change"].double!,
                        changePercent: (json[ticker]["quote"]["changePercent"].double!)*100,
                        isLive: isLive,
                        extendedPrice: json[ticker]["quote"]["extendedPrice"].double!,
                        extendedChangePercent: (json[ticker]["quote"]["extendedChangePercent"].double!)*100,
                        sector: json[ticker]["quote"]["sector"].string!,
                        marketCap: json[ticker]["quote"]["marketCap"].double!,
                        ytdChange: (json[ticker]["quote"]["ytdChange"].double!)*100
                    )
                    quotes.append(quote)
                    //print(json[ticker]["quote"]["latestPrice"].double!)
                }
                completionHandler(quotes)
            }
        })
        
    }
    
    func listCompanies() {
        sendQuery(queryURL: listURL, completionHandler: { (data, response, error) -> Void in
            if let data = data {
                let json = JSON(data)
                for i in 0..<json.count{
                    if json[i]["type"].string! == self.stockTypes.common {
                        let company = Company(ticker: json[i]["symbol"].string!, fullName: json[i]["name"].string!, isCompany: true)
                        Dataholder.allTickers.append(company)
                    } else if json[i]["type"].string! == self.stockTypes.exchangeTraded {
                        let company = Company(ticker: json[i]["symbol"].string!, fullName: json[i]["name"].string!, isCompany: false)
                        Dataholder.allTickers.append(company)
                    }
                }
                //print(json)
            }
        })
    }
    
    func getFinancialsAndStats() {
        //
    }
    
    func getQuote(ticker: String) {
        //
    }
    
    func getEarningsData() {
        //
    }
    
    func getNews() {
        //
    }
    
    func getCompanyLogo() {
        //
    }
}
