//
//  IEXTrading.swift
//  stonks
//
//  Created by Samuel Hobel on 9/28/18.
//  Copyright © 2018 Samuel Hobel. All rights reserved.
//

import Foundation
import SwiftyJSON

//override stockdataapiprotocol functions
class IEXTrading: StockDataAPI {
    
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
    
    override func getChart(timeInterval: Constants.TimeIntervals) {
        let params:[String] = [stockURL, StockAPIManager.shared.getCurrentTicker(), queries.chart, timeFrames[timeInterval]!]
        let queryURL = params.joined(separator: "/")
        
        sendQuery(queryURL: queryURL, completionHandler: { (data, response, error) -> Void in
            if let data = data {
                let json = JSON(data)
                var candle:Candle
                for i in 0..<json.count{
                    candle = Candle(date: json[i]["date"].string!, volume: json[i]["volume"].double!, high: json[i]["high"].double!, low: json[i]["low"].double!, open: json[i]["open"].double!, close: json[i]["close"].double!)
                }
                print(json)
            }
        })
    }
    
    override func getQuotes(tickers: [String], completionHandler: @escaping ([Quote])->Void){
        let params: [String:String] = [
            "symbols": tickers.joined(separator: ","),
            "types": "quote"
        ]
        let queryURL = buildQuery(url: batchURL, params: params)
        sendQuery(queryURL: queryURL, completionHandler: { (data, response, error) -> Void in
            if let data = data {
                let json = JSON(data)
                var quotes:[Quote] = []
                for (ticker,_):(String, JSON) in json {
                    let quote = Quote(
                        symbol: json[ticker]["quote"]["symbol"].string!,
                        latestPrice:json[ticker]["quote"]["latestPrice"].double!,
                        previousClose: json[ticker]["quote"]["previousClose"].double!,
                        change: json[ticker]["quote"]["change"].double!,
                        changePercent: (json[ticker]["quote"]["changePercent"].double!)*100,
                        latestSource: json[ticker]["quote"]["latestSource"].string!,
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
    
    override func listCompanies() {
        sendQuery(queryURL: listURL, completionHandler: { (data, response, error) -> Void in
            if let data = data {
                let json = JSON(data)
                for i in 0..<json.count{
                    if json[i]["type"].string! == self.stockTypes.common || json[i]["type"].string! == self.stockTypes.exchangeTraded {
                        let company = Company(ticker: json[i]["symbol"].string!, fullName: json[i]["name"].string!)
                        Dataholder.allTickers.append(company)
                    }
                }
                //print(json)
            }
        })
    }
    
    private func sendQuery(queryURL: String, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void){
        let sharedSession = URLSession.shared
        
        if let url = URL(string: queryURL) {
            let request = URLRequest(url: url)
            let dataTask = sharedSession.dataTask(with: request, completionHandler: completionHandler)
            dataTask.resume()
        }
    }
    
    private func buildQuery(url: String, params: [String:String]) -> String {
        var paramString = ""
        var counter = 0
        for (key, value) in params {
            if counter == 0 {
                paramString += key + "=" + value
            } else {
                paramString += "&" + key + "=" + value
            }
            counter+=1
        }
        return url + paramString
    }
}
