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
    
    private var baseURL = "https://api.iextrading.com/1.0/stock/"
    private let sharedSession = URLSession.shared

    private var queries = (
        chart: "chart",
        company: "company",
        earnings: "earnings",
        logo: "logo",
        news: "news",
        quote: "quote"
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
        let params = [baseURL, StockAPIManager.shared.currentTicker, queries.chart, timeFrames[timeInterval]]
        let queryURL = buildQuery(params: params as! [String])
        
        if let url = URL(string: queryURL) {
            let request = URLRequest(url: url)
            
            let dataTask = sharedSession.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
                if let data = data {
                    let json = JSON(data)
                    var candle:Candle
                    for i in 0..<json.count{
                        candle = Candle(high: json[i]["high"].float!, low: json[i]["low"].float!, open: json[i]["open"].float!, close: json[i]["close"].float!)
                    }
                    print(json)
                }
            })
            dataTask.resume()
        }
    }
    
    private func buildQuery(params: [String]) -> String{
        var query = ""
        for param in params {
            query += param + "/"
        }
        return query
    }
}
