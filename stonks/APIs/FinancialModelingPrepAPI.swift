//
//  FinancialModelingPrepApi.swift
//  stonks
//
//  Created by Samuel Hobel on 9/21/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import Foundation
import SwiftyJSON
import ObjectMapper
class FinancialModelingPrepAPI: HTTPRequest {
    
    private var baseUrl = "https://fmpcloud.io/api/v3/"
    private var apikey = "759b9c2f6f26d3f6bdd29412cbe52f6c"
    
    public func getIntradayChart(ticker: String, completionHandler: @escaping ([Candle]) -> Void) {
        let url = self.baseUrl + "historical-chart/1min/" + ticker
        let params = [
            "apikey": apikey
        ]
        let queryURL = buildQuery(url: url, params: params)
        sendQuery(queryURL: queryURL, completionHandler: { (data, response, error) -> Void in
            if let data = data {
                let json = JSON(data)
                var candles:[Candle] = []
                let jsonCandleList = json["intradayChart"]
                for i in 0..<jsonCandleList.count{
                    let jsoncandle = jsonCandleList[i]
                    var candle = Candle()
                    candle.close = jsoncandle["close"].double ?? 0
                    candle.open = jsoncandle["open"].double ?? 0
                    candle.high = jsoncandle["high"].double ?? 0
                    candle.low = jsoncandle["low"].double ?? 0
                    candle.volume = jsoncandle["marketVolume"].double ?? 0
                    candle.datetime = jsoncandle["date"].string ?? ""
                    candle.dateLabel = jsoncandle["date"].string ?? ""
                    candles.append(candle)
                }
                completionHandler(candles)
            }
        })
    }

    public func getQuotes(symbols:[String], completionHandler: @escaping ([Quote])->Void){
        let url = self.baseUrl + "quote/" + symbols.joined(separator: ",")
        let params = [
            "apikey": apikey
        ]
        let queryURL = buildQuery(url: url, params: params)
        sendQuery(queryURL: queryURL, completionHandler: { (data, response, error) -> Void in
            if let data = data {
                let json = JSON(data)
                var quotes:[Quote] = []
                for i in 0..<json.count{
                    let quoteJson = json[i]
                    var quote:Quote = Quote()
                    quote.symbol = quoteJson["symbol"].string!
                    quote.latestPrice = quoteJson["price"].double!
                    quote.change = quoteJson["change"].double!
                    quote.changePercent = quoteJson["changesPercentage"].double! / 100.0
                    quote.latestVolume = quoteJson["volume"].int!
                    quote.previousClose = quoteJson["previousClose"].double!
                    quote.week52High = quoteJson["yearHigh"].double!
                    quote.week52Low = quoteJson["yearLow"].double!
                    quote.avgTotalVolume = quoteJson["avgVolume"].int!
                    quote.open = quoteJson["open"].double!
                    quote.peRatio = quoteJson["pe"].double!
                    quotes.append(quote)
                }
                completionHandler(quotes)
            }
        })
    }

}
