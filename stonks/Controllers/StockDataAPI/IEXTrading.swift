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
                    candle = Candle(high: json[i]["high"].float!, low: json[i]["low"].float!, open: json[i]["open"].float!, close: json[i]["close"].float!)
                }
                print(json)
            }
        })
    }
    
    override func getQuotes(tickers: [String]) {
        let params: [String:String] = [
            "symbols": tickers.joined(separator: ","),
            "types": "quote"
        ]
        let queryURL = buildQuery(url: batchURL, params: params)
        sendQuery(queryURL: queryURL, completionHandler: { (data, response, error) -> Void in
            if let data = data {
                let json = JSON(data)
                for (index,subJson):(String, JSON) in json {
                    print(json[index]["quote"]["latestPrice"].double)
                }
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
